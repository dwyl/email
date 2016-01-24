var test         = require('tape');
var sendEmail    = require('../lib/sendemail_gmail');
var dir          = __dirname.split('/')[__dirname.split('/').length-1];
var file         = dir + __filename.replace(__dirname, '') + " > ";
var path         = require('path');
var envpath      = path.resolve(__dirname + '/../.env'); // our .env file in development
require('env2')(envpath);
var redisClient  = require('redis-connection')(); // instantiate redis-connection
var fs           = require('fs');
var TEST_PROFILE = JSON.parse(fs.readFileSync('./test/fixtures/sample_auth_credentials.json', 'utf8'));
// console.log('TEST_PROFILE:', TEST_PROFILE);
var date = new Date().toUTCString();

test(file+'Attempt to sendEmail Using (Expired) TEST Google OAuth Profile', function(t) {
  var options = {
    auth: {
      credentials: TEST_PROFILE
    },
    payload: {
      to: 'contact.nelsonic+test@gmail.com',
      subject: 'Do You Read Me? > ' + date,
      message: 'Hello World!'
    }
  };
  sendEmail(options, function(err, response){
    t.equal(err['code'], 400, 'sendEmail Fails with expired OAuth Token')
    t.end()
  });
});

test(file+'sendEmail Using VALID Google OAuth Profile', function(t) {
  redisClient.get('TEST_PROFILE', function (err, reply) {
    TEST_PROFILE = JSON.parse(reply);
    var options = {
      auth: {
        credentials: TEST_PROFILE
      },
      payload: {
        to: 'contact.nelsonic+test@gmail.com',
        subject: 'Do You Read Me? > ' + date,
        message: 'Hello World!'
      }
    };
    sendEmail(options, function(err, response){
      // t.equal(err['code'], 400, 'sendEmail Fails with expired OAuth Token')
      console.log(' - - - - - - - - - - - - - - - - - - GMAIL api err:');
      console.log(err)
      console.log(' - - - - - - - - - - - - - - - - - - GMAIL api response:');
      console.log(response);
      t.equal(response.labelIds[0], 'SENT', 'Email SENT!')
      t.equal(err, null, 'No Error');
      t.end()
    });
  });
});

test(file+'Shutdown Redis Connection', function(t) {
  redisClient.end();   // ensure redis connection is closed!
  t.equal(redisClient.connected, false, "✓ Connection to Redis Closed");
  t.end()
});
