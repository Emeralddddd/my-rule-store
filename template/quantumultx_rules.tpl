{{ remoteSnippets.apple.main('🍎 苹果服务', '🍎 苹果CDN', 'DIRECT') | quantumultx}}
{{ remoteSnippets.netflix.main('🎬 奈飞影视') | quantumultx}}
{{ remoteSnippets.youtube.main('🎬 奈飞影视') | quantumultx}}
{{ remoteSnippets.advertising.main('🛑 全球拦截') | quantumultx}}
{{ remoteSnippets.telegram.main('📲 电报信息') | quantumultx}}
{{ remoteSnippets.china.main('🎯 全球直连') | quantumultx}}
{{ remoteSnippets.domesticMedia.main('🎯 全球直连') | quantumultx}}
{{ remoteSnippets.publisher.main('🎯 全球直连') | quantumultx}}

# LAN, debugging rules should place above this line
DOMAIN-SUFFIX,local,DIRECT
IP-CIDR,10.0.0.0/8,DIRECT
IP-CIDR,100.64.0.0/10,DIRECT
IP-CIDR,127.0.0.0/8,DIRECT
IP-CIDR,172.16.0.0/12,DIRECT
IP-CIDR,192.168.0.0/16,DIRECT

GEOIP,CN,DIRECT
FINAL,PROXY
