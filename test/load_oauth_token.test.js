// instead of mocking/stubbing out the whole of the Google API
// we only mock the authentication steps
// but then we use a VALID OAuth2 Token for the remainig tests!
// How do we do this...? simple we save a REAL Token to RedisCloud
// and load it here before our tests boot!
var path = require('path');
var env = path.resolve(__dirname + '/../.env');
// console.log('>> ', env);
require('env2')(env);
// Open RedisCloud Connection
var redisClient = require('redis-connection')();
// Fetch the Stringified Token
redisClient.get('VALID_PROFILE', function (err, reply) {
  // var VALID_PROFILE = JSON.parse(reply);
  // // console.log('Profile', reply); // hello world
  // console.log(JSON.stringify(VALID_PROFILE, null, 2));
  // Export the Stringified Token to process.env (so we can use it in our tests)
  process.env.VALID_PROFILE = reply;
  redisClient.end(); // Close the RedisCloud Connection ?
});
