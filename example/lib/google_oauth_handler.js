var redisClient = require('redis-connection')(); // instantiate redis-connection
var JWT = require('jsonwebtoken'); // session stored as a JWT cookie

module.exports = function custom_handler(req, reply, tokens, profile) {
  console.log(tokens, profile);
  if(profile) {
    profile.tokens = tokens; // save the OAuth Token for later
    console.log('custome_handler says: ')
    console.log(JSON.stringify(profile,null,2));
    redisClient.set('VALID_PROFILE', JSON.stringify(profile));
    // extract the relevant data from Profile to store in JWT object
    var session = {
      fistname : profile.name.givenName, // the person's first name e.g: Anita
      image    : profile.image.url,      // profile image url
      id       : profile.id,             // google+ id
      // exp      : Math.floor(new Date().getTime()/1000) + 7*24*60*60, // Epiry in seconds!
      agent    : req.headers['user-agent'],
      access_token: tokens.access_token
    }
    // create a JWT to set as the cookie:
    var token = JWT.sign(session, process.env.JWT_SECRET);

    redisClient.set(profile.id, JSON.stringify(profile), function(err){
      // reply to client with a view
      var link = '<a href="/sendemail">Send a Test Email</a>';
      return reply("Hello " +profile.name.givenName + ", You Logged in Using Google! " + link)
      .state('token', token); // see: http://hapijs.com/tutorials/cookies
    });
  }
  else {
    return reply("Sorry, something went wrong, please try again.");
  }
}
