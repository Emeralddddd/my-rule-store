#!/bin/bash
#
# 自动检测 CorpLink VPN 的 utun 接口，并通过 Surge HTTP API 更新 VPN Direct 策略
#
# 用法:
#   ./detect-vpn-utun.sh              # 检测一次并更新
#   ./detect-vpn-utun.sh --watch      # 持续监控，接口变化时自动更新
#
# 前置条件:
#   1. Surge → 设置 → HTTP API → 开启，记下密码和端口
#   2. 设置下方环境变量，或在 Surge 配置中添加:
#      http-api = YOUR_PASSWORD@127.0.0.1:6171
#

# ============ 配置 ============
SURGE_API_PORT="${SURGE_API_PORT:-6171}"
SURGE_API_PASSWORD="${SURGE_API_PASSWORD:-}"  # 留空则不带认证头
SURGE_API="http://127.0.0.1:${SURGE_API_PORT}"
POLICY_NAME="VPN Direct"
WATCH_INTERVAL=5  # 监控模式检测间隔（秒）

# ============ 函数 ============

# 检测非 Surge 的 VPN utun 接口（有 IPv4 地址且非 198.18.x.x）
detect_vpn_utun() {
    for iface in $(ifconfig -l | tr ' ' '\n' | grep '^utun'); do
        local inet
        inet=$(ifconfig "$iface" 2>/dev/null | awk '/inet / {print $2}')
        [ -z "$inet" ] && continue

        # 跳过 Surge TUN（198.18.0.0/15）
        [[ "$inet" == 198.18.* || "$inet" == 198.19.* ]] && continue

        echo "$iface"
        return 0
    done
    return 1
}

# 获取 utun 的 IPv4 地址
get_utun_ip() {
    ifconfig "$1" 2>/dev/null | awk '/inet / {print $2}'
}

# 构建 curl 认证头
auth_header() {
    if [ -n "$SURGE_API_PASSWORD" ]; then
        echo "-H" "X-Key: ${SURGE_API_PASSWORD}"
    fi
}

# 通过 Surge HTTP API 更新策略
update_surge_policy() {
    local iface="$1"
    local encoded_name
    encoded_name=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$POLICY_NAME'))")

    local policy_value="direct, interface=${iface}, allow-other-interface=true"

    local response
    if [ -n "$SURGE_API_PASSWORD" ]; then
        response=$(curl -s -o /dev/null -w "%{http_code}" \
            -X PUT "${SURGE_API}/v1/policies/${encoded_name}" \
            -H "Content-Type: application/json" \
            -H "X-Key: ${SURGE_API_PASSWORD}" \
            -d "{\"policy\": \"${policy_value}\"}" 2>&1)
    else
        response=$(curl -s -o /dev/null -w "%{http_code}" \
            -X PUT "${SURGE_API}/v1/policies/${encoded_name}" \
            -H "Content-Type: application/json" \
            -d "{\"policy\": \"${policy_value}\"}" 2>&1)
    fi

    if [ "$response" = "200" ]; then
        echo "[$(date '+%H:%M:%S')] ✅ 已更新「${POLICY_NAME}」→ interface=${iface} ($(get_utun_ip "$iface"))"
        return 0
    else
        echo "[$(date '+%H:%M:%S')] ❌ Surge API 返回 HTTP ${response}"
        echo "  请确认: 1) Surge HTTP API 已开启  2) 端口=${SURGE_API_PORT}  3) 密码正确"
        return 1
    fi
}

# 单次检测并更新
run_once() {
    local iface
    iface=$(detect_vpn_utun)
    if [ -z "$iface" ]; then
        echo "[$(date '+%H:%M:%S')] ⚠️  未检测到 VPN utun 接口（飞连可能未连接）"
        return 1
    fi

    local ip
    ip=$(get_utun_ip "$iface")
    echo "[$(date '+%H:%M:%S')] 🔍 检测到 VPN 接口: ${iface} (${ip})"
    update_surge_policy "$iface"
}

# 监控模式：持续检测，变化时更新
run_watch() {
    echo "=== VPN utun 监控模式 (每 ${WATCH_INTERVAL}s 检测) ==="
    echo "按 Ctrl+C 退出"
    echo ""

    local last_iface=""

    while true; do
        local iface
        iface=$(detect_vpn_utun)

        if [ "$iface" != "$last_iface" ]; then
            if [ -n "$iface" ]; then
                local ip
                ip=$(get_utun_ip "$iface")
                echo "[$(date '+%H:%M:%S')] 🔄 VPN 接口变化: ${last_iface:-无} → ${iface} (${ip})"
                update_surge_policy "$iface"
            else
                echo "[$(date '+%H:%M:%S')] ⚠️  VPN 接口消失（飞连已断开？）"
            fi
            last_iface="$iface"
        fi

        sleep "$WATCH_INTERVAL"
    done
}

# ============ 主逻辑 ============

case "${1:-}" in
    --watch|-w)
        run_watch
        ;;
    *)
        run_once
        ;;
esac
