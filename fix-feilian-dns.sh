#!/usr/bin/env bash

set -euo pipefail

PUBLIC_DNS="${PUBLIC_DNS:-198.18.0.2}"
CORP_DOMAINS_CSV="${CORP_DOMAINS_CSV:-byted.org,bytedance.net}"
CORP_LOOPBACK_V4="${CORP_LOOPBACK_V4:-127.0.0.1}"
CORP_LOOPBACK_V6="${CORP_LOOPBACK_V6:-::1}"
SERVICE_IF="${SERVICE_IF:-}"
ACTION="apply"
ORIGINAL_ARGS=("$@")

OLD_IFS="$IFS"
IFS=','
read -r -a CORP_DOMAINS <<< "$CORP_DOMAINS_CSV"
IFS="$OLD_IFS"

[[ "${#CORP_DOMAINS[@]}" -gt 0 ]] || {
  printf '[fix-feilian-dns] CORP_DOMAINS_CSV is empty\n' >&2
  exit 1
}

log() {
  printf '[fix-feilian-dns] %s\n' "$*"
}

die() {
  log "$*" >&2
  exit 1
}

usage() {
  cat <<'EOF'
Usage:
  ./fix-feilian-dns.sh [--check] [--service utunX] [--public-dns IP]

Behavior:
  - Default action rewrites macOS dynamic-store DNS state so that:
    - public/default DNS uses PUBLIC_DNS
    - CorpLink loopback DNS only matches CORP_DOMAINS_CSV
  - --check prints the current DNS state without changing anything

Examples:
  ./fix-feilian-dns.sh --check
  ./fix-feilian-dns.sh
  ./fix-feilian-dns.sh --service utun5 --public-dns 198.18.0.2

Notes:
  - This is a temporary workaround. CorpLink may overwrite it after reconnect.
  - The default PUBLIC_DNS is Surge's 198.18.0.2 fake-IP DNS.
  - The default internal suffixes are byted.org and bytedance.net.
EOF
}

detect_service_if() {
  if [[ -n "$SERVICE_IF" ]]; then
    printf '%s\n' "$SERVICE_IF"
    return
  fi

  local detected
  detected="$(
    scutil --dns | awk -v corp_domains="$CORP_DOMAINS_CSV" '
      BEGIN {
        block=0
        loopback=0
        corp=0
        iface=""
        found=0
        count=split(corp_domains, domains, ",")
      }
      /^resolver #[0-9]+/ {
        if (block && loopback && corp && iface != "") {
          print iface
          found=1
          exit
        }
        block=1
        loopback=0
        corp=0
        iface=""
      }
      /nameserver\[0\] : 127\.0\.0\.1/ { loopback=1 }
      {
        for (i = 1; i <= count; i++) {
          if (domains[i] != "" && index($0, domains[i])) {
            corp=1
          }
        }
      }
      /if_index : [0-9]+ \(utun[0-9]+\)/ {
        iface=$0
        sub(/^.*\(/, "", iface)
        sub(/\).*$/, "", iface)
      }
      END {
        if (!found && block && loopback && corp && iface != "") {
          print iface
        }
      }
    ' | head -n1
  )"

  [[ -n "$detected" ]] || die "Failed to detect the active CorpLink utun service."
  printf '%s\n' "$detected"
}

show_state() {
  local service_if="${1:-$(detect_service_if)}"

  log "Wi-Fi DNS:"
  networksetup -getdnsservers Wi-Fi || true

  log "Dynamic-store DNS state:"
  scutil <<EOF
show State:/Network/Global/DNS
show State:/Network/Service/${service_if}/DNS
EOF
}

apply_workaround() {
  local service_if
  service_if="$(detect_service_if)"

  if [[ "${EUID}" -ne 0 ]]; then
    log "Root privileges are required. Re-running with sudo."
    exec sudo \
      PUBLIC_DNS="$PUBLIC_DNS" \
      CORP_DOMAINS_CSV="$CORP_DOMAINS_CSV" \
      CORP_LOOPBACK_V4="$CORP_LOOPBACK_V4" \
      CORP_LOOPBACK_V6="$CORP_LOOPBACK_V6" \
      SERVICE_IF="$service_if" \
      "$0" "${ORIGINAL_ARGS[@]}"
  fi

  log "Applying workaround to ${service_if}"
  log "Public/default DNS -> ${PUBLIC_DNS}"
  log "CorpLink loopback DNS -> ${CORP_LOOPBACK_V4}, ${CORP_LOOPBACK_V6} for ${CORP_DOMAINS_CSV//,/, } only"

  scutil <<EOF
d.init
d.add ServerAddresses * ${PUBLIC_DNS}
set State:/Network/Global/DNS

d.init
d.add ServerAddresses * ${CORP_LOOPBACK_V4} ${CORP_LOOPBACK_V6}
d.add SupplementalMatchDomains * ${CORP_DOMAINS[*]}
d.add ServerPort 53
set State:/Network/Service/${service_if}/DNS
quit
EOF

  dscacheutil -flushcache >/dev/null 2>&1 || true
  killall -HUP mDNSResponder >/dev/null 2>&1 || true

  log "Workaround applied. Current state:"
  show_state "$service_if"
  log "Suggested verification:"
  log "  dig cip.cc"
  log "  dig bytedance.net"
  log "  curl https://cip.cc/"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --check)
      ACTION="check"
      shift
      ;;
    --service)
      [[ $# -ge 2 ]] || die "Missing value for --service"
      SERVICE_IF="$2"
      shift 2
      ;;
    --public-dns)
      [[ $# -ge 2 ]] || die "Missing value for --public-dns"
      PUBLIC_DNS="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "Unknown argument: $1"
      ;;
  esac
done

case "$ACTION" in
  check)
    show_state
    ;;
  apply)
    apply_workaround
    ;;
  *)
    die "Unsupported action: $ACTION"
    ;;
esac
