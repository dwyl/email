var google = require('googleapis');
var OAuth2 = google.auth.OAuth2;
var gmail  = google.gmail('v1');
console.log(gmail.users.messages.send.toString()); // https://git.io/vz8RT

console.log(new Buffer('Hello World!').toString('base64'));

var btoa = require('btoa');
var base64EncodedEmail = btoa(
      "Content-Type:  text/plain; charset=\"UTF-8\"\n" +
      "Content-length: 5000\n" +
      "Content-Transfer-Encoding: message/rfc2822\n" +
      "to: dwyl.test@gmail.com\n" +
      "from: \"test\" <contact.nelsonic@gmail.com>\n" +
      "subject: Hello world!\n\n" +

      "The actual message text goes here"
        ).replace(/\+/g, '-').replace(/\//g, '_');
console.log(base64EncodedEmail);
