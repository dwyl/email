/**
 * sendEmail abstracts the complexity of sending an email via the GMail API
 * @param {Object} options - the options for your email, these include:
 *  - credentials
 *    - {Object} tokens - the list of tokens returned after Google OAuth
 *    - {Array} emails - the current user's email addresses (List)
 *  - {String} to - the recipient of the email
 *  - {String} from - sender address
 *  - {String} message - the message you want to send
 * @param {Function} callback - gets called once the message has been sent
 *   your callback should accept two arguments:
 *   @arg {Object} error - the error returned by the GMail API
 *   @arg {Object} response - response sent by GMail API
 */
module.exports = function sendEmail(options, callback) {

}
