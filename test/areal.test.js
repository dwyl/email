var test   = require('tape');
var dir    = __dirname.split('/')[__dirname.split('/').length-1];
var file   = dir + __filename.replace(__dirname, '') + " > ";
var JWT    = require('jsonwebtoken');
var server = require('../example/server.js');
var TEST_JWT, TEST_PROFILE;
var date   = new Date().toUTCString(); // used in tests
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
var redisClient = require('redis-connection')('subscriber');

test(file+'GET REAL (TEST) OAuth2 Token & Profile', function(t) {
  redisClient.get('TEST_PROFILE', function (err, reply) {
    process.env.VALID_PROFILE = reply;
    TEST_PROFILE = JSON.parse(reply);
    // console.log(' - - - - - - - - - TEST_PROFILE: ')
    // console.log(JSON.stringify(TEST_PROFILE, null, 2));
  });
  redisClient.get('TEST_JWT', function (err, reply) {
    process.env.VALID_PROFILE = reply;
    TEST_JWT = 'token=' + reply;
    // console.log(' - - - - - - - - - TEST_JWT: ')
    // console.log(TEST_JWT);
    t.end();
  });
});

test(file+'POST /sendemail email', function(t) {
  var options = {
    method: "POST",
    url: "/sendemail",
    headers: { cookie:  TEST_JWT },
    payload: {
      "to" : "contact.nelsonic@gmail.com",
      "message" : "its time!",
      "subject" : "realTest 1 > " + date
    }
  };
  server.inject(options, function(response) {
    // console.log(response.result);
    t.equal(response.statusCode, 200, "Successfully SENT Email via GMAIL!");
    // setTimeout(function(){ server.stop(t.end); }, 100);
    server.stop(function(){
      t.end()
    });
  });
});

test(file+'POST basic data to /compose email', function(t) {
  var options = {
    method: "POST",
    url: "/compose",
    headers: { cookie: TEST_JWT },
    payload: {
      "to" : "contact.nelsonic@gmail.com",
      "subject" : "aReal Test on " + date,
      "message" : "Totes a Test!"
    }
  };
  server.inject(options, function(response) {
    // console.log(response.result);
    t.equal(response.statusCode, 200, "Successfully Sent an Email!");
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
