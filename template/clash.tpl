# {{ downloadUrl }}

external-controller: 127.0.0.1:9090
port: 7890
socks-port: 7891
redir-port: 7892

{% if customParams.dns %}
dns:
  enable: true # 启用自定义DNS
  ipv6: false # default is false
  listen: 0.0.0.0:1053
  enhanced-mode: fake-ip
  fake-ip-range: 198.18.0.1/16 # if you don't know what it is, don't change it
  default-nameserver:
    - 180.76.76.76
    - 223.5.5.5
    - 119.29.29.29
  nameserver:
    - https://doh.pub/dns-query
    - https://dns.alidns.com/dns-query

  fallback:
    - tls://1.1.1.1:853
    - tls://1.0.0.1:853
    - 101.6.6.6:5353
{% endif %}

proxies: {{ getClashNodes(nodeList) | json }}

proxy-groups:
  - type: select
    name: 🚀 节点选择
    proxies: ['HK','US','JP','SG']
  - name: 🎬 Disney+
    type: select
    proxies:
      - 🚀 节点选择
      - US
      - HK
      - SG
  - name: 🎬 HBO Max
    type: select
    proxies:
      - 🚀 节点选择
      - US
      - HK
      - SG
  - name: 🎬 Netflix
    type: select
    proxies:
      - 🚀 节点选择
      - US
      - HK
      - SG
  - name: 🎬 Bahamut
    type: select
    proxies:
      - 🚀 节点选择
      - HK
      - SG
  - name: 📺 YouTube
    type: select
    proxies:
      - 🚀 节点选择
      - US
      - HK
      - SG
  - name: 📺 Bilibili
    type: select
    proxies:
      - 🎯 全球直连
      - US
      - HK
      - SG
  - name: 🎵 Spotify
    type: select
    proxies:
      - 🚀 节点选择
      - US
      - HK
      - SG
  - name: 🎮 Steam
    type: select
    proxies:
      - 🚀 节点选择
      - US
      - HK
      - SG
  - name: 💬 Telegram
    type: select
    proxies:
      - 🚀 节点选择
      - US
      - HK
      - SG
  - name: 🤖 OpenAI
    type: select
    proxies:
      - 🚀 节点选择
      - US
      - HK
      - SG
      - 🎯 全球直连
  - name: 💳 PayPal
    type: select
    proxies:
      - 🚀 节点选择
      - US
      - HK
      - SG
  - name: 🍎 Apple
    type: select
    proxies:
      - 🎯 全球直连
      - 🚀 节点选择
      - US
      - HK
      - SG
  - name: 🔍 Google
    type: select
    proxies:
      - 🎯 全球直连
      - 🚀 节点选择
      - US
      - HK
      - SG
  - name: 🖥️ Microsoft
    type: select
    proxies:
      - 🎯 全球直连
      - 🚀 节点选择
      - US
      - HK
      - SG
  - name: 🌍 Global
    type: select
    proxies:
      - 🚀 节点选择
      - US
      - HK
      - SG
  - name: 🇨🇳 China
    type: select
    proxies:
      - 🎯 全球直连
      - 🚀 节点选择
      - US
      - HK
      - SG
  - name: 🏠 LAN
    type: select
    proxies:
      - DIRECT
  - name: 🔓 Unbreak
    type: select
    proxies:
      - DIRECT
  - name: 🎯 全球直连
    type: select
    proxies:
      - DIRECT
  - name: 🛑 全球拦截
    type: select
    proxies:
      - REJECT
      - DIRECT
  - name: 🐟 漏网之鱼
    type: select
    proxies:
      - 🚀 节点选择
      - 🎯 全球直连
  - type: fallback
    name: US
    proxies: {{ getClashNodeNames(nodeList, usFilter) | json }}
    url: {{ proxyTestUrl }}
    interval: 1200
  - type: fallback
    name: HK
    proxies: {{ getClashNodeNames(nodeList, hkFilter) | json }}
    url: {{ proxyTestUrl }}
    interval: 1200
  - type: fallback
    name: JP
    proxies: {{ getClashNodeNames(nodeList, japanFilter) | json }}
    url: {{ proxyTestUrl }}
    interval: 1200
  - type: fallback
    name: SG
    proxies: {{ getClashNodeNames(nodeList, singaporeFilter) | json }}
    url: {{ proxyTestUrl }}
    interval: 1200

rules:
{{ remoteSnippets.unbreak.main('🔓 Unbreak') | clash }}
{{ remoteSnippets.youtube.main('📺 YouTube') | clash }}
{{ remoteSnippets.disney.main('🎬 Disney+') | clash }}
{{ remoteSnippets.hbomax.main('🎬 HBO Max') | clash }}
{{ remoteSnippets.netflix.main('🎬 Netflix') | clash }}
{{ remoteSnippets.bahamut.main('🎬 Bahamut') | clash }}
{{ remoteSnippets.bilibili.main('📺 Bilibili') | clash }}
{{ remoteSnippets.spotify.main('🎵 Spotify') | clash }}
{{ remoteSnippets.steam.main('🎮 Steam') | clash }}
{{ remoteSnippets.telegram.main('💬 Telegram') | clash }}
{{ remoteSnippets.google.main('🔍 Google') | clash }}
{{ remoteSnippets.microsoft.main('🖥️ Microsoft') | clash }}
{{ remoteSnippets.openai.main('🤖 OpenAI') | clash }}
{{ remoteSnippets.paypal.main('💳 PayPal') | clash }}
{{ remoteSnippets.apple.main('🍎 Apple') | clash }}
{{ remoteSnippets.global.main('🌍 Global') | clash }}
{{ remoteSnippets.china.main('🇨🇳 China') | clash }}
{{ remoteSnippets.lan.main('🏠 LAN') | clash }}

# LAN
- DOMAIN-SUFFIX,local,DIRECT
- IP-CIDR,127.0.0.0/8,DIRECT
- IP-CIDR,172.16.0.0/12,DIRECT
- IP-CIDR,192.168.0.0/16,DIRECT
- IP-CIDR,10.0.0.0/8,DIRECT
- IP-CIDR,100.64.0.0/10,DIRECT

# QNAP
- DOMAIN-KEYWORD,qnap,DIRECT

# Final
- GEOIP,CN,DIRECT
- MATCH,🐟 漏网之鱼
