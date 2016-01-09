require('env2')('.env');
var assert = require('assert');
var Hapi   = require('hapi'); // require the hapi module
var server = new Hapi.Server({ debug: { request: ['error'] } });

server.connection({
	host: 'localhost',
	port: Number(process.env.PORT) // defined by environment variable or .env file
});

var scopes = [
  'https://www.googleapis.com/auth/plus.profile.emails.read',
  'https://www.googleapis.com/auth/calendar.readonly',
  'https://www.googleapis.com/auth/gmail.send'
];
console.log(scopes);

var opts = {
  REDIRECT_URL: '/googleauth',  // must match google app redirect URI
  handler: require('./lib/google_oauth_handler.js'), // your handler
  scope: scopes // profile
};

var google = require('googleapis');
var OAuth2 = google.auth.OAuth2;
// var gcal = google.calendar('v3'); // http://git.io/vBGLn
var gmail  = google.gmail('v1');
var oauth2Client = new OAuth2(process.env.GOOGLE_CLIENT_ID, process.env.GOOGLE_CLIENT_SECRET, opts.REDIRECT_URL);
var btoa = require('btoa');

var hapi_auth_google = require('hapi-auth-google');
var sendEmail = require('./lib/sendemail-gmail');

var plugins = [
	{ register: hapi_auth_google, options:opts },
	require('hapi-auth-jwt2')
];
server.register(plugins, function (err) {
  // handle the error if the plugin failed to load:
  assert(!err, "FAILED TO LOAD PLUGIN!!! :-("); // fatal error
	// see: http://hapijs.com/api#serverauthschemename-scheme
  server.auth.strategy('jwt', 'jwt', true,
  { key: process.env.JWT_SECRET,
    validateFunc: require('./lib/hapi_auth_jwt2_validate.js'),
    verifyOptions: { ignoreExpiration: true }
  });

  server.route([{
    method: 'GET',
    path: '/',
    config: { auth : false },
    handler: function(request, reply) {
      var url    = server.generate_google_oauth2_url();
  		var imgsrc = 'https://developers.google.com/accounts/images/sign-in-with-google.png';
  		var btn    = '<a href="' + url +'"><img src="' +imgsrc +'" alt="Login With Google"></a>'
      reply(btn);
    }
  },
  {
    method: 'GET',
    path: '/sendemail',
    config: { auth : 'jwt' },
    handler: function(request, reply) {
			sendEmail(request, function(err, response){
				console.log(' - - - - - - - - - - - - - - - - - - GMAIL api err:');
        console.log(err)
        console.log(' - - - - - - - - - - - - - - - - - - GMAIL api response:');
        console.log(response);
        reply('<pre><code>'+JSON.stringify(response, null, 2)+'</code></pre>');
			});
    }
  }
  ]);

});

server.start(function(err){ // boots your server
  console.log(' - - - - - - - - - - - -  Hapi Server Version: '+server.version);
  // console.log(err)
  // console.log(' - - - - - - - - - - - - - - - - - -');
  assert(!err, "FAILED TO Start Server", err);
	console.log('Now Visit: http://localhost:'+server.info.port);
});

module.exports = server;
