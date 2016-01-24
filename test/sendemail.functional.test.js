var test         = require('tape');
var dir          = __dirname.split('/')[__dirname.split('/').length-1];
var file         = dir + __filename.replace(__dirname, '') + " > ";
var path         = require('path');
var envpath      = path.resolve(__dirname + '/../.env'); // our .env file in development
require('env2')(envpath);
var redisClient  = require('redis-connection')(); // instantiate redis-connection
var fs           = require('fs');
var TEST_PROFILE = JSON.parse(fs.readFileSync('./test/fixtures/sample_auth_credentials.json', 'utf8'));
// console.log('TEST_PROFILE:', TEST_PROFILE);
var REAL_PROFILE;


test(file+'Shutdown Redis Connection', function(t) {
  redisClient.end();   // ensure redis connection is closed!
  t.equal(redisClient.connected, false, "✓ Connection to Redis Closed");
  t.end()
});
