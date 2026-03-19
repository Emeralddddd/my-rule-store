# {{ downloadUrl }}

[General]
bypass-tun = 10.0.0.0/8,100.64.0.0/10,127.0.0.0/8,169.254.0.0/16,172.16.0.0/12,192.0.0.0/24,192.0.2.0/24,192.88.99.0/24,192.168.0.0/16,198.18.0.0/15,198.51.100.0/24,203.0.113.0/24,224.0.0.0/4,255.255.255.255/32
skip-proxy = 127.0.0.1,192.168.0.0/16,10.0.0.0/8,172.16.0.0/12,100.64.0.0/10,17.0.0.0/8,localhost,*.local,passenger.t3go.cn
dns-server = system,119.29.29.29,223.5.5.5
doh-server = https://dns.alidns.com/dns-query,https://doh.pub/dns-query
proxy-test-url = {{ proxyTestUrl }}
internet-test-url = http://www.aliyun.com
test-timeout = 5
interface-mode = auto
allow-wifi-access = false

[Proxy]
{{ getLoonNodes(nodeList) }}
{{ customParams.vpsName }} = Shadowsocks,{{ customParams.vpsServer }},{{ customParams.vpsPort }},{{ customParams.vpsEncryptMethod }},"{{ customParams.vpsPassword }}",udp=true

[Remote Proxy]

[Proxy Group]
🚀 节点选择 = select,🇺🇸 美国,🇭🇰 香港,🇯🇵 日本,🇸🇬 新加坡
🇺🇸 美国 = select,🇺🇸 Auto US,{{ getLoonNodeNames(nodeList, usFilter) }}
🇺🇸 Auto US = fallback,{{ getLoonNodeNames(nodeList, usFilter) }},url={{ proxyTestUrl }},interval=1200
🇭🇰 香港 = select,🇭🇰 Auto HK,{{ getLoonNodeNames(nodeList, hkFilter) }}
🇭🇰 Auto HK = fallback,{{ getLoonNodeNames(nodeList, hkFilter) }},url={{ proxyTestUrl }},interval=1200
🇯🇵 日本 = select,🇯🇵 Auto JP,{{ getLoonNodeNames(nodeList, japanFilter) }}
🇯🇵 Auto JP = fallback,{{ getLoonNodeNames(nodeList, japanFilter) }},url={{ proxyTestUrl }},interval=1200
🇸🇬 新加坡 = select,🇸🇬 Auto SG,{{ getLoonNodeNames(nodeList, singaporeFilter) }}
🇸🇬 Auto SG = fallback,{{ getLoonNodeNames(nodeList, singaporeFilter) }},url={{ proxyTestUrl }},interval=1200
🎵 Spotify = select,🚀 节点选择,🇺🇸 美国,🇭🇰 香港,🇯🇵 日本,🇸🇬 新加坡
🎬 Disney+ = select,🚀 节点选择,🇺🇸 美国,🇭🇰 香港,🇯🇵 日本,🇸🇬 新加坡
🎬 HBO Max = select,🚀 节点选择,🇺🇸 美国,🇭🇰 香港,🇯🇵 日本,🇸🇬 新加坡
🎬 Netflix = select,🚀 节点选择,🇺🇸 美国,🇭🇰 香港,🇯🇵 日本,🇸🇬 新加坡
🎬 Bahamut = select,🚀 节点选择,🇭🇰 香港,🇸🇬 新加坡
📺 YouTube = select,🚀 节点选择,🇺🇸 美国,🇭🇰 香港,🇯🇵 日本,🇸🇬 新加坡
📺 Bilibili = select,🎯 全球直连,🇺🇸 美国,🇭🇰 香港,🇯🇵 日本,🇸🇬 新加坡
🎮 Steam = select,🚀 节点选择,🇺🇸 美国,🇭🇰 香港,🇯🇵 日本,🇸🇬 新加坡
💬 Telegram = select,🚀 节点选择,🇺🇸 美国,🇭🇰 香港,🇯🇵 日本,🇸🇬 新加坡
🤖 OpenAI = select,🚀 节点选择,🇺🇸 美国,🇭🇰 香港,🇯🇵 日本,🇸🇬 新加坡,🎯 全球直连
🧠 Claude = select,{{ customParams.vpsName }},🚀 节点选择,🇺🇸 美国,🇭🇰 香港,🇯🇵 日本,🇸🇬 新加坡,🎯 全球直连
💳 PayPal = select,🚀 节点选择,🇺🇸 美国,🇭🇰 香港,🇯🇵 日本,🇸🇬 新加坡
🍎 Apple = select,🎯 全球直连,🚀 节点选择,🇺🇸 美国,🇭🇰 香港,🇯🇵 日本,🇸🇬 新加坡
🔍 Google = select,🎯 全球直连,🚀 节点选择,🇺🇸 美国,🇭🇰 香港,🇯🇵 日本,🇸🇬 新加坡
🖥️ Microsoft = select,🎯 全球直连,🚀 节点选择,🇺🇸 美国,🇭🇰 香港,🇯🇵 日本,🇸🇬 新加坡
🌍 Global = select,🚀 节点选择,🇺🇸 美国,🇭🇰 香港,🇯🇵 日本,🇸🇬 新加坡
🇨🇳 China = select,🎯 全球直连,🚀 节点选择,🇺🇸 美国,🇭🇰 香港,🇯🇵 日本,🇸🇬 新加坡
🏠 LAN = select,DIRECT
🔓 Unbreak = select,DIRECT
🎯 全球直连 = select,DIRECT
🛑 全球拦截 = select,DIRECT,REJECT
🐟 漏网之鱼 = select,🚀 节点选择,🎯 全球直连

[Remote Filter]

[Rule]
{{ remoteSnippets.unbreak.main('🔓 Unbreak') | loon }}
{{ remoteSnippets.youtube.main('📺 YouTube') | loon }}
{{ remoteSnippets.disney.main('🎬 Disney+') | loon }}
{{ remoteSnippets.hbomax.main('🎬 HBO Max') | loon }}
{{ remoteSnippets.netflix.main('🎬 Netflix') | loon }}
{{ remoteSnippets.bahamut.main('🎬 Bahamut') | loon }}
{{ remoteSnippets.bilibili.main('📺 Bilibili') | loon }}
{{ remoteSnippets.spotify.main('🎵 Spotify') | loon }}
{{ remoteSnippets.steam.main('🎮 Steam') | loon }}
{{ remoteSnippets.telegram.main('💬 Telegram') | loon }}
{{ remoteSnippets.google.main('🔍 Google') | loon }}
{{ remoteSnippets.microsoft.main('🖥️ Microsoft') | loon }}
{{ remoteSnippets.openai.main('🤖 OpenAI') | loon }}
{{ remoteSnippets.claude.main('🧠 Claude') | loon }}
{{ remoteSnippets.paypal.main('💳 PayPal') | loon }}
{{ remoteSnippets.apple.main('🍎 Apple') | loon }}
{{ remoteSnippets.global.main('🌍 Global') | loon }}
{{ remoteSnippets.china.main('🇨🇳 China') | loon }}
{{ remoteSnippets.lan.main('🏠 LAN') | loon }}

# LAN
IP-CIDR,10.0.0.0/8,DIRECT
IP-CIDR,127.0.0.0/8,DIRECT
IP-CIDR,172.16.0.0/12,DIRECT
IP-CIDR,192.168.0.0/16,DIRECT
IP-CIDR,100.64.0.0/10,DIRECT

# QNAP
DOMAIN-KEYWORD,qnap,DIRECT

GEOIP,CN,DIRECT
FINAL,🐟 漏网之鱼

[Remote Rule]

[URL Rewrite]

[Script]

[MITM]
hostname =
