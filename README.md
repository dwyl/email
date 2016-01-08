# Send Email > Gmail

Send email from any Node.js app using Google (Gmail)

## Why?

We have been using Mandrill for sending email @dwyl
and we made a node module for this: https://github.com/dwyl/sendemail

However we have had requests from *clients* to send email via Gmail.
And have implemented this:
https://github.com/dwyl/html-form-send-email-via-google-script-without-server

*However* ... the amount of *setup* required to use Mandrill is quite
*daunting* to beginners.
see: https://github.com/dwyl/sendemail#checklist-everything-you-need-to-get-started-in-5-minutes

## What?

+ Send *any type* of email using Gmail
+ Authenticate using OAuth.
+ Track emails sent
+ Track open rates

## How?

#### *Required* Environment Variables

+ `GOOGLE_CLIENT_ID` - your google OAuth client id.

> If you need a quick primer on Google OAuth see:  
https://github.com/dwyl/hapi-auth-google



Running this app or its' tests on your local machine will require
that you set a few
[*environment variables*](https://github.com/dwyl/learn-environment-variables)
our *preferred* method is to use [`env2`](https://github.com/dwyl/env2)
and load our environment variables in an `.env` file.

Using your terminal or text editor, create your `.env` file.  
Then *paste* this *sample* into your `.env` file:

```txt
GOOGLE_CLIENT_ID=ClientIdGoesHere
GOOGLE_CLIENT_SECRET=YourSecretHere
```
...*replace the values for the ones you got from Google*

If you want to *contribute* to this project,
contact us for our "*Test*" Google OAuth Credentials.
