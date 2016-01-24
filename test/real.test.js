var test   = require('tape');
var dir    = __dirname.split('/')[__dirname.split('/').length-1];
var file   = dir + __filename.replace(__dirname, '') + " > ";
var JWT    = require('jsonwebtoken');
var server = require('../example/server.js');
var VALID_PROFILE;
// instead of mocking/stubbing out the whole of the Google API
// we only mock the authentication steps in mock.test.js
// but then we use a VALID OAuth2 Token for the remainig tests!
// How do we do this...? simple, we store a REAL Token in RedisCloud
// and load it here before our tests boot!
var path = require('path');
var env = path.resolve(__dirname + '/../.env'); // our .env file in development
// console.log('>> ', env);
require('env2')(env);
// Open RedisCloud Connection
var redisClient = require('redis-connection')();
// Fetch the Stringified Token

test(file+'GET Real OAuth2 Tokens', function(t) {
  redisClient.get('VALID_PROFILE', function (err, reply) {
    // // console.log('Profile', reply); // hello world
    // Export the Stringified Token to process.env (so we can use it in our tests)
    process.env.VALID_PROFILE = reply;
    VALID_PROFILE = JSON.parse(reply);
    console.log(' - - - - - - - - - ')
    console.log(JSON.stringify(VALID_PROFILE, null, 2));
    t.end();
  });
});

test(file+'POST basic data to /compose email', function(t) {
  console.log(' - - - - - - - - - - - - - - - - - - cookie:');
  console.log(COOKIE);
  var options = {
    method: "POST",
    url: "/compose",
    headers: { cookie: COOKIE },
    payload: {
      "to" : "nelson@dwyl.io",
      "message" : "its time!"
    }
  };
  server.inject(options, function(response) {
    console.log(response.result);
    t.equal(response.statusCode, 200, "Successfully showing /compose page");
    // setTimeout(function(){ server.stop(t.end); }, 100);
    server.stop(function(){
      t.end()
    });
  });
});


test(file+'Shutdown Redis Connection', function(t) {
  redisClient.end();   // ensure redis con closed! - \\
  t.equal(redisClient.connected, false, "✓ Connection to Redis Closed");
  server.stop(function(){
    t.end()
  });
});
