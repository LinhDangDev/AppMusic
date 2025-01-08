const NodeCache = require('node-cache');

// Cache với TTL 1 giờ
const cache = new NodeCache({ 
  stdTTL: 3600,
  checkperiod: 120
});

module.exports = cache; 