// instead of mocking/stubbing out the whole of the Google API
// we only mock the authentication steps
// but then we use a VALID OAuth2 Token for the remainig tests!
// How do we do this...? simple we save a REAL Token to RedisCloud
// and load it here before our tests boot!
require('env2')('../.env');
var redisClient = require('redis-connection')();

console.log(process.env);
// Open RedisCloud Connection

// Fetch the Stringified Token

// Export the Stringified Token to process.env (so we can use it in our tests)

// Close the RedisCloud Connection ?
