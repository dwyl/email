var test = require('tape');
var nock = require('nock');
var nock_options = {allowUnmocked: true};

var redisClient = require('redis-connection')(); // instantiate redis-connection
var dir  = __dirname.split('/')[__dirname.split('/').length-1];
var file = dir + __filename.replace(__dirname, '') + " > ";
var server = require('../example/server.js');

test(file+'MOCK Google OAuth2 Flow /googleauth?code=mockcode', function(t) {
  // google oauth2 token request url:
  var fs = require('fs');
  var token_fixture = fs.readFileSync('./test/fixtures/sample-auth-token.json');
  var scope = nock('https://accounts.google.com', nock_options)
            .persist() // https://github.com/pgte/nock#persist
            .post('/o/oauth2/token')
            .reply(200, token_fixture);

  // see: http://git.io/v4nTR for google plus api url
  // https://www.googleapis.com/plus/v1/people/{userId}
  var sample_profile = fs.readFileSync('./test/fixtures/sample-profile.json');
  var scope = nock('https://www.googleapis.com', nock_options)
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
    // console.log(' - - - - - - - - - - - - - - - - - - cookie:');
    // console.log(response.headers);
    COOKIE = response.headers['set-cookie'][0]; //.split('=')[1];
    redisClient.end();   // ensure redis connection is closed!
    server.stop(t.end);
  });
});
