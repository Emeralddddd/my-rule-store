#!/usr/bin/env node
/**
 * 自动检测 CorpLink VPN 的 utun 接口，并通过 Surge HTTP API 切换「🏢 内网VPN」策略组
 *
 * 原理:
 *   Surge 配置中预定义了 VPN utun0 ~ VPN utun15 共 16 个 direct 代理，
 *   每个绑定不同的 utun 接口。脚本检测到 VPN 使用的 utun 后，
 *   通过 policy_groups/select API 热切换策略组，无需 reload。
 *
 * 用法:
 *   node detect-vpn-utun.js              # 检测一次并切换
 *   node detect-vpn-utun.js --watch      # 持续监控，接口变化时自动切换
 *
 * 环境变量:
 *   SURGE_API_PORT     - Surge HTTP API 端口 (默认 6171)
 *   SURGE_API_PASSWORD - Surge HTTP API 密码
 */

const os = require("os");
const http = require("http");
const { spawn } = require("child_process");

// ============ 配置 ============
const SURGE_API_PORT = process.env.SURGE_API_PORT || 6171;
const SURGE_API_PASSWORD = process.env.SURGE_API_PASSWORD || "xuzhizhen";
const GROUP_NAME = "🏢 内网VPN";

// ============ 核心检测 ============

function detectVpnUtun() {
  const interfaces = os.networkInterfaces();
  for (const [name, addrs] of Object.entries(interfaces)) {
    if (!name.startsWith("utun")) continue;
    const v4 = addrs.find((a) => a.family === "IPv4");
    if (!v4) continue;
    if (v4.address.startsWith("198.18.") || v4.address.startsWith("198.19."))
      continue;
    return { name, ip: v4.address };
  }
  return null;
}

// ============ Surge HTTP API ============

function surgeApiRequest(method, path, body) {
  return new Promise((resolve, reject) => {
    const headers = { "Content-Type": "application/json" };
    if (SURGE_API_PASSWORD) headers["X-Key"] = SURGE_API_PASSWORD;

    const payload = body ? JSON.stringify(body) : null;
    if (payload) headers["Content-Length"] = Buffer.byteLength(payload);

    const req = http.request(
      { hostname: "127.0.0.1", port: SURGE_API_PORT, path, method, headers },
      (res) => {
        let data = "";
        res.on("data", (chunk) => (data += chunk));
        res.on("end", () => resolve({ status: res.statusCode, data }));
      }
    );
    req.on("error", reject);
    if (payload) req.write(payload);
    req.end();
  });
}

async function switchGroupPolicy(policyName) {
  try {
    const { status, data } = await surgeApiRequest(
      "POST",
      "/v1/policy_groups/select",
      { group_name: GROUP_NAME, policy: policyName }
    );
    if (status === 200) {
      log(`已切换「${GROUP_NAME}」-> ${policyName}`);
      return true;
    } else {
      log(`Surge API 返回 HTTP ${status}: ${data}`);
      return false;
    }
  } catch (err) {
    log(`Surge API 请求失败: ${err.message}`);
    return false;
  }
}

// ============ 日志 ============

function timestamp() {
  return new Date().toLocaleTimeString("zh-CN", { hour12: false });
}

function log(msg) {
  console.log(`[${timestamp()}] ${msg}`);
}

// ============ 单次检测 ============

async function runOnce() {
  const vpn = detectVpnUtun();
  if (!vpn) {
    log("未检测到 VPN utun 接口（飞连可能未连接）");
    return false;
  }
  log(`检测到 VPN 接口: ${vpn.name} (${vpn.ip})`);
  const policyName = `VPN ${vpn.name}`;
  return switchGroupPolicy(policyName);
}

// ============ 监控模式 ============

function runWatch() {
  console.log("=== VPN utun 监控模式 (基于路由事件) ===");
  console.log("按 Ctrl+C 退出\n");

  let lastIface = null;

  function check() {
    const vpn = detectVpnUtun();
    const currentIface = vpn ? vpn.name : null;

    if (currentIface !== lastIface) {
      if (vpn) {
        log(`VPN 接口变化: ${lastIface || "无"} -> ${vpn.name} (${vpn.ip})`);
        switchGroupPolicy(`VPN ${vpn.name}`);
      } else {
        log("VPN 接口消失（飞连已断开？）");
      }
      lastIface = currentIface;
    }
  }

  check();

  const routeMonitor = spawn("route", ["monitor"], {
    stdio: ["ignore", "pipe", "ignore"],
  });

  let debounceTimer = null;
  routeMonitor.stdout.on("data", () => {
    if (debounceTimer) clearTimeout(debounceTimer);
    debounceTimer = setTimeout(check, 1000);
  });

  routeMonitor.on("error", (err) => {
    log(`route monitor 启动失败: ${err.message}，回退到轮询模式`);
    setInterval(check, 5000);
  });

  routeMonitor.on("close", (code) => {
    if (code !== null) {
      log(`route monitor 退出 (code=${code})，回退到轮询模式`);
      setInterval(check, 5000);
    }
  });

  process.on("SIGINT", () => {
    routeMonitor.kill();
    console.log("\n已退出");
    process.exit(0);
  });
}

// ============ 主逻辑 ============

const args = process.argv.slice(2);
if (args.includes("--watch") || args.includes("-w")) {
  runWatch();
} else {
  runOnce().then((ok) => process.exit(ok ? 0 : 1));
}
