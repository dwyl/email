var path = require('path');
var env = path.resolve(__dirname + '/../.env'); // our .env file in development
// console.log('>> ', env);
require('env2')(env);

var test = require('tape');
var nock = require('nock');
var nock_options = {allowUnmocked: true};

var redisClient = require('redis-connection')(); // instantiate redis-connection
var dir  = __dirname.split('/')[__dirname.split('/').length-1];
var file = dir + __filename.replace(__dirname, '') + " > ";
var JWT  = require('jsonwebtoken');
var server = require('../example/server.js');

test(file + 'test the response on / is a link to Google Auth', function(t){
  var options = {
    method: "GET",
    url: "/"
  };

  server.inject(options, function(response) {
    // console.log(response.result);
    t.equal(response.result.indexOf('sign-in-with-google.png') > -1, true, 'Displays link');
    setTimeout(function(){
      // redisClient.end();   // ensure redis con closed! - \\
      // t.equal(redisClient.connected, false, "✓ Connection to Redis Closed");
      server.stop(t.end)
    }, 100);
  });
});

test(file+'Ensure the server does not 500 when /googleauth?code=badcode', function(t) {
  var options = {
    method: "GET",
    url: "/googleauth?code=badcode"
  };
  server.inject(options, function(response) {
    t.equal(response.statusCode, 200, "Server is working.");
    t.ok(response.payload.indexOf('something went wrong') > -1,
          'Got: '+response.payload + ' (Mock!)');
    server.stop(function(){ });
    t.end();
  });
});

var COOKIE; // we get this in the response in the next test:

test(file+'Visit /sendemail with INVALID JWT Cookie', function(t) {
  var token = JWT.sign({ id: 321, "name": "Charlie" }, process.env.JWT_SECRET);
  var options = {
    method: "POST",
    url: "/sendemail",
    headers: { cookie: "token=" + token },
    payload: {
      "to" : "contact.nelsonic@gmail.com",
      "message" : "this will not get sent...",
      "subject" : "Mock Test "
    }
  };
  server.inject(options, function(response) {
    // console.log(' - - - - - - - - - - - - - - - - - - result:');
    // console.log(response.result);
    t.equal(response.statusCode, 401, "Auth Blocked by bad Cookie JWT");
    // setTimeout(function(){ server.stop(t.end); }, 100);
    server.stop(function(){
      t.end()
    });
  });
});

test(file+'Attempt to POST /sendemail using Mock OAuth Token', function(t) {
  var options = {
    method: "POST",
    url: "/sendemail",
    headers: { cookie: COOKIE },
    payload: {
      "to" : "contact.nelsonic+sendemail.test@gmail.com",
      "message" : "this will not get sent...",
      "subject" : "Mock Test "
    }
  };
  server.inject(options, function(response) {
    console.log(' - - - - - - - - - - - - - - - - - - result:');
    console.log(response.result);
    t.equal(response.statusCode, 401, "Auth Blocked by bad Cookie JWT");
    // setTimeout(function(){ server.stop(t.end); }, 100);
    server.stop(function(){
      t.end()
    });
  });
});


// test(file+'Shutdown Redis Connection', function(t) {
//   redisClient.end();   // ensure redis connection is closed!
//   t.equal(redisClient.connected, false, "✓ Connection to Redis Closed");
//   t.end()
// });
