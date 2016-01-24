var path = require('path');
var env = path.resolve(__dirname + '/../.env'); // our .env file in development
// console.log('>> ', env);
require('env2')(env);

var test = require('tape');
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
    console.log(response.result);
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
          'Got: '+response.payload + ' (As Expected)');
    server.stop(function(){ });
    t.end();
  });
});

var COOKIE; // we get this in the response in the next test:

test(file+'MOCK Google OAuth2 Flow /googleauth?code=mockcode', function(t) {
  // google oauth2 token request url:
  var fs = require('fs');
  var token_fixture = fs.readFileSync('./test/fixtures/sample-auth-token.json');
  var nock = require('nock');
  var scope = nock('https://accounts.google.com')
            .persist() // https://github.com/pgte/nock#persist
            .post('/o/oauth2/token')
            .reply(200, token_fixture);

  // see: http://git.io/v4nTR for google plus api url
  // https://www.googleapis.com/plus/v1/people/{userId}
  var sample_profile = fs.readFileSync('./test/fixtures/sample-profile.json');
  var nock = require('nock');
  var scope = nock('https://www.googleapis.com')
            .get('/plus/v1/people/me')
            .reply(200, sample_profile);


  var options = {
    method: "GET",
    url: "/googleauth?code=mockcode"
  };
  server.inject(options, function(response) {
    t.equal(response.statusCode, 200, "Profile retrieved (Mock)");
    var expected = 'Logged in Using Google!';
    t.ok(response.payload.indexOf(expected) > -1, "Got: " + expected + " (as expected)");
    console.log(' - - - - - - - - - - - - - - - - - - cookie:');
    console.log(response.headers);
    COOKIE = response.headers['set-cookie'][0]; //.split('=')[1];
    // console.log(COOKIE);
    // console.log(' - - - - - - - - - - - - - - - - - - decoded:');
    // console.log(JWT.decode(COOKIE));
    server.stop(t.end);
  });
});


test(file+'Visit /sendemail with INVALID JWT Cookie', function(t) {
  var token = JWT.sign({ id: 321, "name": "Charlie" }, process.env.JWT_SECRET);
  var options = {
    method: "GET",
    url: "/sendemail",
    headers: { cookie: "token=" + token }
  };
  server.inject(options, function(response) {
    console.log(' - - - - - - - - - - - - - - - - - - result:');
    console.log(response.result);
    t.equal(response.statusCode, 401, "Auth Blocked by bad Cookie JWT");
    // setTimeout(function(){ server.stop(t.end); }, 100);
    server.stop(function(){
      redisClient.end();
      t.end()
    });
  });
});


// test(file+'Shutdown Redis Connection', function(t) {
//   redisClient.end();   // ensure redis con closed! - \\
//   t.equal(redisClient.connected, false, "✓ Connection to Redis Closed");
//   // server.stop(function(){
//     t.end()
//   // });
// });
