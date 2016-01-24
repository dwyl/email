var redisClient = require('redis-connection')(); // instantiate redis-connection
// bring your own validation function
module.exports = function validate (decoded, request, callback) {
  console.log(" - - - - - - - DECODED token:");
  console.log(decoded);
  // do your checks to see if the session is valid
  redisClient.get(decoded.id, function (rediserror, redisreply) {
    var profile;
    console.log(rediserror, redisreply);
    if(!rediserror && redisreply) {
      profile = JSON.parse(redisreply);
      console.log(' - - - - - - - REDIS reply - - - - - - - ');
      console.log( JSON.stringify(profile, null, 2) );
      return callback(rediserror, true, profile); // profile is acccessible as request.auth.credentials
    }
    else { // unable to find session in redis ... reply is null
      console.log(rediserror);
      return callback(rediserror);
    }
  });
};
