'use strict';
const { utils } = require('surgio');
const { readProviderUrl } = require('./env');

module.exports = {
    renameNode: name => {
        return '🌸' + name;
    },
    type: 'clash',
    url: readProviderUrl('PROVIDER_FLOWER_CLOUD_URL'),
    udpRelay: true,
};
