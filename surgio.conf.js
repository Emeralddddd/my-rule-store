'use strict';

const { utils } = require('surgio');

const requireEnv = key => {
  const value = process.env[key];
  if (!value) {
    throw new Error(`Missing environment variable ${key}`);
  }
  return value;
};

const parseJsonEnv = key => {
  const value = requireEnv(key);
  try {
    return JSON.parse(value);
  } catch (error) {
    throw new Error(`Invalid JSON in environment variable ${key}: ${error.message}`);
  }
};

const ensureFields = (value, fields, key) => {
  fields.forEach(field => {
    if (!value[field]) {
      throw new Error(`Missing field "${field}" in environment variable ${key}`);
    }
  });
};

const normalizeRelayNode = (value, key, fallbackName) => {
  const relayNode = {
    name: value.name || fallbackName,
    type: value.type || 'socks5',
    server: value.server,
    port: value.port,
    username: value.username,
    password: value.password,
    underlyingProxy: value.underlyingProxy || '🚀 节点选择',
  };
  if (relayNode.type !== 'socks5') {
    throw new Error(`Unsupported relay node type "${relayNode.type}" in ${key}`);
  }
  ensureFields(relayNode, ['server', 'port', 'username', 'password'], key);
  return relayNode;
};

const parseRelayNodes = () => {
  const relayNodes = parseJsonEnv('RELAY_NODES');
  if (!Array.isArray(relayNodes)) {
    throw new Error('Environment variable RELAY_NODES must be a JSON array');
  }
  return relayNodes.map((relayNode, index) =>
    normalizeRelayNode(relayNode, `RELAY_NODES[${index}]`, `Relay ${index + 1}`)
  );
};

const isIpv4Address = value => /^\d{1,3}(?:\.\d{1,3}){3}$/.test(value);

const surgeVps = parseJsonEnv('SURGE_VPS');
const relayNodes = parseRelayNodes();
ensureFields(surgeVps, ['server', 'port', 'password'], 'SURGE_VPS');
const vpsName = surgeVps.name || 'vps';
const customFilters = {
  ytoo: utils.useProviders(['ytoo'], false),
  flowerCloud: utils.useProviders(['flowerCloud'], false),
};

const relayProxyGroupName = '🪜 中转节点';
const relayNodeGroupMembers = [
  vpsName,
  ...relayNodes.map(relayNode => relayNode.name),
];

/**
 * 使用文档：https://surgio.royli.dev/
 */
module.exports = {
  /**
   * 远程片段
   * 文档：https://surgio.royli.dev/guide/custom-config.html#remotesnippets
   */
  remoteSnippets: [
    {
      name: 'unbreak',
      url: 'https://raw.githubusercontent.com/AGWA5783/Profiles/master/Surge/Ruleset/Unbreak.list'
    },
    {
      name: 'youtube',
      url: 'https://raw.githubusercontent.com/AGWA5783/Profiles/master/Surge/Ruleset/StreamingMedia/Video/YouTube.list'
    },
    {
      name: 'disney',
      url: 'https://raw.githubusercontent.com/AGWA5783/Profiles/master/Surge/Ruleset/StreamingMedia/Video/DisneyPlus.list'
    },
    {
      name: 'hbomax',
      url: 'https://raw.githubusercontent.com/AGWA5783/Profiles/master/Surge/Ruleset/StreamingMedia/Video/HBO-USA.list'
    },
    {
      name: 'netflix',
      url: 'https://raw.githubusercontent.com/AGWA5783/Profiles/master/Surge/Ruleset/StreamingMedia/Video/Netflix.list'
    },
    {
      name: 'bahamut',
      url: 'https://raw.githubusercontent.com/AGWA5783/Profiles/master/Surge/Ruleset/StreamingMedia/Video/Bahamut.list'
    },
    {
      name: 'bilibili',
      url: 'https://raw.githubusercontent.com/AGWA5783/Profiles/master/Surge/Ruleset/StreamingMedia/StreamingSE.list'
    },
    {
      name: 'spotify',
      url: 'https://raw.githubusercontent.com/AGWA5783/Profiles/master/Surge/Ruleset/StreamingMedia/Music/Spotify.list'
    },
    {
      name: 'steam',
      url: 'https://raw.githubusercontent.com/AGWA5783/Profiles/master/Surge/Ruleset/Extra/Game/Steam.list'
    },
    {
      name: 'telegram',
      url: 'https://raw.githubusercontent.com/AGWA5783/Profiles/master/Surge/Ruleset/Extra/Telegram/Telegram.list'
    },
    {
      name: 'google',
      url: 'https://raw.githubusercontent.com/AGWA5783/Profiles/master/Surge/Ruleset/Extra/Google/Google.list'
    },
    {
      name: 'microsoft',
      url: 'https://raw.githubusercontent.com/AGWA5783/Profiles/master/Surge/Ruleset/Extra/Microsoft/Microsoft.list'
    },
    {
      name: 'openai',
      url: 'https://raw.githubusercontent.com/AGWA5783/Profiles/master/Surge/Ruleset/Extra/OpenAI/OpenAI.list'
    },
    {
      name: 'claude',
      url: 'https://raw.githubusercontent.com/Emeralddddd/Snippets/master/claude.list'
    },
    {
      name: 'paypal',
      url: 'https://raw.githubusercontent.com/AGWA5783/Profiles/master/Surge/Ruleset/Extra/PayPal.list'
    },
    {
      name: 'apple',
      url: 'https://raw.githubusercontent.com/AGWA5783/Profiles/master/Surge/Ruleset/Extra/Apple/Apple.list'
    },
    {
      name: 'global',
      url: 'https://raw.githubusercontent.com/AGWA5783/Profiles/master/Surge/Ruleset/Global.list'
    },
    {
      name: 'china',
      url: 'https://raw.githubusercontent.com/AGWA5783/Profiles/master/Surge/Ruleset/China.list'
    },
    {
      name: 'lan',
      url: 'https://raw.githubusercontent.com/AGWA5783/Profiles/master/Surge/Ruleset/LocalAreaNetwork.list'
    },
    {
      name: 'bytedance',
      url: 'https://raw.githubusercontent.com/Emeralddddd/Snippets/master/bytedance.list'
    },
    {
      name: 'providerSubscription',
      url: 'https://raw.githubusercontent.com/Emeralddddd/Snippets/master/provider-subscription.list'
    },
  ],
  customFilters: customFilters,
  artifacts: [
    /**
     * Surge
     */
    // 合并 Provider
    {
      name: 'Full.conf',
      template: 'surge_v3',
      provider: 'demo',
      combineProviders: ['flowerCloud', 'ytoo'],
    },
    // Surge + SSR
    // {
    //   name: 'SurgeV3_ssr.conf',
    //   template: 'surge_v3',
    //   provider: 'ssr_subscribe_demo',
    // },

    /**
     * Clash
     */
    {
      name: 'Full.yaml',
      template: 'clash',
      provider: 'demo',
      combineProviders: ['flowerCloud', 'ytoo'],
    },
    {
      name: 'Tiny.yaml',
      template: 'clash',
      provider: 'demo',
      combineProviders: ['flowerCloud', 'ytoo'],
    },
    {
      name: 'QX_Tiny.conf',
      template: 'quantumultx',
      provider: 'demo',
      combineProviders: ['ytoo']
    },

    /**
     * Loon
     */
    {
      name: 'Loon.conf',
      template: 'loon',
      provider: 'demo',
      combineProviders: ['flowerCloud', 'ytoo'],
    }
  ],
  /**
   * 订阅地址的前缀部分，以 / 结尾
   * 例如阿里云 OSS 的访问地址 https://xxx.oss-cn-hangzhou.aliyuncs.com/
   */
  urlBase: requireEnv('OSS_URL_BASE'),
  surgeConfig: {
    v2ray: 'native', // 默认 'native', 可选 'external'
    shadowsocksFormat: 'ss', // 默认 'ss', 可选 'custom'
    resolveHostname: true,
  },
  customParams: {
    dns: true,
    vpsName,
    vpsServer: surgeVps.server,
    vpsPort: surgeVps.port,
    vpsEncryptMethod: surgeVps.encryptMethod || 'chacha20-ietf-poly1305',
    vpsPassword: surgeVps.password,
    vpsUnderlyingProxy: surgeVps.underlyingProxy || '🚀 节点选择',
    relayProxyGroupName,
    relayNodes,
    relayNodeGroupMembers,
    relayNodesWithIpServer: relayNodes.filter(relayNode => isIpv4Address(relayNode.server)),
    relayClashProxies: relayNodes.map(relayNode => ({
      name: relayNode.name,
      type: relayNode.type,
      server: relayNode.server,
      port: relayNode.port,
      username: relayNode.username,
      password: relayNode.password,
      'dialer-proxy': relayNode.underlyingProxy,
      udp: true,
    })),
  },
  binPath: {
    // 安装教程: https://surgio.royli.dev/guide/install-ssr-local.html
    shadowsocksr: '/usr/local/bin/ssr-local',
  },
  upload: {
    // 默认保存至根目录，可以在此修改子目录名，以 / 结尾，默认为 /
    prefix: '/',
    bucket: 'emerald-surgio',
    // 支持所有区域
    region: 'oss-cn-shanghai',
    // 以下信息于阿里云控制台获得
    accessKeyId: requireEnv('ALIYUN_ACCESS_KEY_ID'),
    accessKeySecret: requireEnv('ALIYUN_ACCESS_KEY_SECRET'),
  },
  // 非常有限的报错信息收集
  analytics: true,
};
