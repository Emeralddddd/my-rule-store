'use strict';

/**
 * Read a provider URL from environment variables. Throwing early keeps secrets
 * out of the repo while failing fast during local runs or CI.
 * @param {string} key
 * @returns {string}
 */
function readProviderUrl(key) {
  const value = process.env[key];
  if (!value) {
    throw new Error(`Missing environment variable ${key}`);
  }
  return value;
}

module.exports = {
  readProviderUrl,
};
