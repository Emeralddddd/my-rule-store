'use strict';
const { utils } = require('surgio');
const { readProviderUrl } = require('./env');

module.exports = {
    renameNode: name => {
        return '😈' + name;
    },
    type: 'shadowsocks_subscribe',
    url: readProviderUrl('PROVIDER_KUROMIS_URL'),
    udpRelay: true,
};
