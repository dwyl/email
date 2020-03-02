# `email` 💌

[![Build Status](https://img.shields.io/travis/dwyl/email/master.svg?style=flat-square)](https://travis-ci.org/dwyl/email)
[![codecov.io](https://img.shields.io/codecov/c/github/dwyl/email/master.svg?style=flat-square)](http://codecov.io/github/dwyl/email?branch=master)
<!--
[![HitCount](http://hits.dwyl.com/dwyl/email.svg)](http://hits.dwyl.com/dwyl/email)
-->

## Why? 🤷‍

We needed a way to keep track of **`email`** in our App. <br />
We want to know precise stats for deliverability,
click-through and bounce rates for the emails we send
in real-time. <br />
This allows us to monitor the "health" of our
[feedback loop](https://en.wikipedia.org/wiki/Feedback)
and be more data-driven in our communications.



## What? 💭

An **`email` analytics dashboard** for our App.

```
The main App does not do any Email as that is is not it's core function.
It delegates all email sending and monitoring activity to the aws-ses-lambda.

┌─────┐  send   ┌────────────────┐
| App | ───────>| aws-ses-lambda |─┐ The Lambda function Sends email
└─────┘  email  └────────────────┘ | and handles SNS notifications
                                   | for bounce events.
  ┌───────┐    SNS Notification    |
  | Email | <──────────────────────┘
  |  App  |
  └───────┘  
  The Email Stats App aggregates and visualises email stats.
  This allows us to be more data-driven in our communications.
  And understand exactly who is engaged with the app.

  This is not a full on  it's just an attempt to make email
  sending/monitoring separate so our App can focus on core features.
```


## Who? 👤

We are building this App
for our own (_internal_) use
[`@dwyl`](https://github.com/dwyl/app/issues/267). <br />
As with ***everything*** we do,
it's **Open Source** and **_extensively_ documented**
so others can _learn_ from it.

If you find this interesting or useful,
please ⭐️the repository on GitHub! <br />
If you have any feedback/questions,
please [open an issue](https://github.com/dwyl/email/issues)



## How?


To _run_ the **`email`** App, follow these instructions:

### Get the Code

**`git clone`** this project from GitHub:

```
git clone git@github.com:dwyl/email.git && cd email
```

### Dependencies

Install the dependencies:

```sh
mix deps.get
cd assets && npm install && cd ..
```

### Environment Variables

Ensure you have the environment variables defined
for the Phoenix App, specifically the
`DATABASE_URL` and `SECRET_KEY_BASE`

In our case we are reusing the `SECRET_KEY_BASE`
to verify JWTs.
That means that the `SECRET_KEY_BASE`
of the Phoenix App needs to be exported
as the `JWT_SECRET` in the Lambda function.





### Deploy the Lambda Function

In our case the `aws-ses-lambda` function
is deployed _automatically_
by **Travis-CI** (_continuous delivery_).
For anyone else following along,
please read the instructions in
https://github.com/dwyl/aws-ses-lambda
to deploy the Lambda function;
there are quite a few steps but they work!

Provided you have:<br />
**a.** created the SNS Topic, <br />
**b.** subscribed to SES notifications on the topic <br />
**c.** made it the trigger for Lambda function,<br />
**d.** defined all the necessary environment varialbes for the Lambda,<br />
you should be all set.
These steps are all described in detail in:
[`SETUP.md`](https://github.com/dwyl/aws-ses-lambda/blob/master/SETUP.md)

If you get stuck
getting this running
or have any questions/suggestions,
please [open an issue](https://github.com/dwyl/aws-ses-lambda/issues).





<br /> <br />

### Want to _Understand How_ we Made This? 🤷‍

If you want to _recreate_ the **`email`** app from scratch,
follow all the steps outlined here.

If you are adding the **`email`** functionality
to an _existing_ App,
you can **skip** to **step 2**. <br />
If you are creating an **`email`**
functionality and dashboard from scratch,
follow steps 0 and 1.

### 0. Create a New Phoenix App 🆕

In your terminal, run the following mix command:

```elixir
mix phx.new app
```

That will create a few files.
e.g: [github.com/dwyl/email/commit/1c999be](https://github.com/dwyl/email/commit/1c999be3fff75e42fcb6e62e1f2a152764ce3b74)

Follow the instructions in the terminal to download all the dependencies.

At this point the **`email`** App
is just a basic "hello world" Phoenix App. <br />
It should be familiar to you
if you have followed any of the Phoenix tutorials, <br />
e.g: https://github.com/dwyl/phoenix-chat-example
or https://github.com/dwyl/phoenix-todo-list-tutorial



### 1. Copy the Migration Files from the MVP 📋

In order to speed up our development of the **`email`** App,
we are _only_ going to create _one_ schema/table; **`sent`** (_see: step 2_).
Since our app will refer to email addresses,
we need a **`people`** schema which

See: [github.com/dwyl/email/commit/bcafb2f](https://github.com/dwyl/email/commit/bcafb2fbd92782b1e166305428c5211690374b2e)

#### 1.b Copy the `person.ex` and `status.ex` Schemas

In order to have the _schema_ for the `person` and `status`,
which is required to insert a `sent` record
because `sent` has fields for `person_id` and `status_id`,


In my case given that I had the `app-mvp-phoenix` on my `localhost`,
I just ran the following commands:
```
cp ../app-mvp-phoenix/lib/app/ctx/person.ex ./lib/app/ctx/
cp ../app-mvp-phoenix/lib/app/ctx/status.ex ./lib/app/ctx/
```

`person.ex` depends on a couple of functions contained in
`app-mvp-phoenix/lib/app/ctx.ex`
_specifically_ `App.Ctx.get_status_verified/0`.
Open `../app-mvp-phoenix/lib/app/ctx.ex` in your editor window,
or web browser:
[`app-mvp-phoenix/lib/app/ctx.ex`](https://github.com/dwyl/app-mvp-phoenix/blob/d0b43ba3ee95bc292cdf4d79fffab5bfed36198a/lib/app/ctx.ex)

Locate the `get_status_verified/0` function:

```elixir
def get_status_verified() do
  Repo.get_by(Status, text: "verified")
end
```
Copy it and paste it into `/lib/app/ctx/person.ex`.

We also need to add the following aliases
to the top of the `person.ex` file:
```elixir
alias App.Ctx.Status
alias App.Repo
```

The code for these changes is contained in
[dwyl/email/commit/81fa2a9](https://github.com/dwyl/email/commit/81fa2a9d79f1685f3362dc1e6debb049fcf9d7f6)



#### _Why reuse_ migrations?

Our objective is to be able to run the **`email`** App in several ways:

1. **Independently** from any "main" App.
So the **`email`** dashboard can be 100% anonymised
and we just display _aggregate_ stats for all email being sent/received.

2. **Inside** the "main" App.
If we don't want to have to deploy _separate_ Apps,
we can simply include the **`email`** functionality within a "main" App.

3. **Umbrella App** where the **`email`** App
is run as a "child" to the "main" app.

By reusing the **migration** files from our "main" App,
(_the files need to have the **exact same name** and contents_),
we maintain full flexibility to run our **`email`** App in any way.
This is because if we run the migrations against the "main" PostgreSQL DB,
the migrations with those timestamps will _already_ exist
in the **`migrations`** table; so no change will be required.
However


### 2. Create the `sent` Schema/Table 📤

In order to store the data on the emails that have been sent,
we need to create the **`sent`** schema:

```elixir
mix phx.gen.html Ctx Sent sent message_id:string person_id:references:people request_id:string status_id:references:status template:string
```

When you run this command in your terminal,
you should see the following output
showing all the files that were created:

```
* creating lib/app_web/controllers/sent_controller.ex
* creating lib/app_web/templates/sent/edit.html.eex
* creating lib/app_web/templates/sent/form.html.eex
* creating lib/app_web/templates/sent/index.html.eex
* creating lib/app_web/templates/sent/new.html.eex
* creating lib/app_web/templates/sent/show.html.eex
* creating lib/app_web/views/sent_view.ex
* creating test/app_web/controllers/sent_controller_test.exs
* creating lib/app/ctx/sent.ex
* creating priv/repo/migrations/20200224224024_create_sent.exs
* creating lib/app/ctx.ex
* injecting lib/app/ctx.ex
* creating test/app/ctx_test.exs
* injecting test/app/ctx_test.exs

Add the resource to your browser scope in lib/app_web/router.ex:

    resources "/sent", SentController

Remember to update your repository by running migrations:

$ mix ecto.migrate
```

We will follow these instructions in the next steps!

#### Why So Many Files?

When using `mix phx.gen.html` to create a set of phoenix resources,
the files for the migration, context, controller, views, templates
and tests are generated.
This is a _good_ thing because Phoenix does all the work for us
and we don't have to think about any of the "boilerplate" code.
It can feel like a lot of code
especially if you are new to Phoenix,
but don't get hung up on it.
Right now we are only interested in the _migration_ file:
[`/priv/repo/migrations/20200224224024_create_sent.exs`](https://github.com/dwyl/email/blob/master/priv/repo/migrations/20200224224024_create_sent.exs)


Feel free to read through the other files created in step 2:
[github.com/dwyl/email/commit/b8d4b06](https://github.com/dwyl/email/commit/b8d4b062f2bd358d35395e0dafd252f2bb3d5be8)
The code is fairly straightforward,
but if there is ***anything*** you **_don't_ understand**,
[***please ask!***](https://github.com/dwyl/email/issues)

We are not doing much with these files in the next few steps,
but we will return to them later when work on the dashboard!



#### What are the `message_id` and `request_id` fields for?

In case you are wondering what the
**`message_id`** and **`request_id`** fields
in the **`sent`** schema are for.
The **`message_id`** is,
as you would expect,
the _Globally Unique_ ID (GUID)
for the message in the AWS SES system.
We need to keep track of this ID because
all SNS notifications will reference it.
So if we receive a "delivered" or "bounce" SNS notification,
we need to match it up to the original **`message_id`**
so that our data reflects the **`status`** of the message.

The [`aws-ses-lambda`](https://github.com/dwyl/aws-ses-lambda) function
returns a response in the following form:

```js
{
  MessageId: '010201703dd218c7-ae82fd07-9c08-4215-a4a9-4b723b98d8f3-000000',
  ResponseMetadata: {
    RequestId: 'def1b013-331e-4d10-848e-6f0dbd709434'
  }
}
```

Or when invoked from Elixir
see:
[github.com/dwyl/elixir-invoke-lambda-example](https://github.com/dwyl/elixir-invoke-lambda-example)
the response is:

```elixir
{:ok,
 %{
   "MessageId" => "010201703dd218c7-ae82fd07-9c08-4215-a4a9-4b723b98d8f3-000000",
   "ResponseMetadata" => %{
     "RequestId" => "def1b013-331e-4d10-848e-6f0dbd709434"
   }
 }}
```

We are storing `MessageId` as `message_id`
and `RequestId` as `request_id`.


### 3. Add the SentController Resources to `router.ex`

Open the
`lib/app_web/router.ex`
file
and locate the section that starts with
```elixir
scope "/", AppWeb do
```
Add the following line in that scope:

```elixir
resources "/sent", SentController
```

e.g: [/lib/app_web/router.ex#L20](https://github.com/dwyl/email/blob/db1abd0cc075d27b7cd2bfc37019fc33dd5d0585/lib/app_web/router.ex#L20)


### 4. Run the Migrations


In your terminal run the migrations command:

```elixir
mix ecto.migrate
```

You should expect to see outpout similar to the following:

```
23:15:48.568 [info]  == Running 20200224224024 App.Repo.Migrations.CreateSent.change/0 forward

23:15:48.569 [info]  create table sent

23:15:48.574 [info]  create index sent_person_id_index

23:15:48.575 [info]  create index sent_status_id_index

23:15:48.576 [info]  == Migrated 20200224224024 in 0.0s
```

#### Entity Relationship Diagram (ERD)

ERD after creating the **`sent`** table:

![erd-with-sent-table](https://user-images.githubusercontent.com/194400/75200073-b6944700-575c-11ea-97c9-a7b495395a05.png)


### Checkpoint: Run the App!

Just to get an idea for what the `/sent` page _currently_ looks like,
let's run the Phoenix App and view it. <br />
In your terminal run:

```elixir
mix phx.server
```

Then visit: http://localhost:4000/sent
in your web browser. <br />
You should expect to see:

![visit-sent-in-browser](https://user-images.githubusercontent.com/194400/75242300-b8432680-57bf-11ea-80ae-d84a1195e69c.png)

Click on the "New sent" link to create a new **`sent`** record.
You should see a form similar to this:

![new-sent](https://user-images.githubusercontent.com/194400/75242477-16700980-57c0-11ea-83c9-66c3d2a1c307.png)

Input some test data and click "**Save**". <br />
You will be redirected to: http://localhost:4000/sent/1
with the message "**Sent created successfully**":


![created-successfully](https://user-images.githubusercontent.com/194400/75242487-1bcd5400-57c0-11ea-82c1-9aacb04fa1d3.png)

_Obviously_ we are not going to create
the **`sent`** records _manually_ like this. <br />
(_in fact we will be disabling this form later on_) <br />
For now we just want to know that record creation is working.

If you return to the http://localhost:4000/sent (`index`) route,
you should see the one "sent" item:

![sent-showing-one-record](https://user-images.githubusercontent.com/194400/75242625-62bb4980-57c0-11ea-9865-7bd81dc230ee.png)

This confirms that our `sent` schema is working as we expect.


#### Run the Tests!

For good measure, let's run the tests:

```elixir
mix test
```

You should expect to see output similar to the following:

```sh
11:23:09.268 [info]  Already up
...................

Finished in 0.2 seconds
19 tests, 0 failures

Randomized with seed 448418
```

19 tests, 0 failures.

#### Test Coverage!

Follow the
[instructions to add code coverage](https://github.com/dwyl/phoenix-chat-example#15-what-is-not-tested). <br />
Then run:

```sh
mix coveralls
```

You should expect to see:

```sh
Finished in 0.2 seconds
19 tests, 0 failures

Randomized with seed 938602
----------------
COV    FILE                                        LINES RELEVANT   MISSED
100.0% lib/app.ex                                      9        0        0
100.0% lib/app/ctx.ex                                104        6        0
100.0% lib/app/ctx/sent.ex                            21        2        0
100.0% lib/app/repo.ex                                 5        0        0
100.0% lib/app_web/channels/user_socket.ex            33        0        0
100.0% lib/app_web/controllers/page_controller.        7        1        0
100.0% lib/app_web/controllers/sent_controller.       62       19        0
100.0% lib/app_web/endpoint.ex                        47        0        0
100.0% lib/app_web/gettext.ex                         24        0        0
100.0% lib/app_web/views/error_view.ex                16        1        0
100.0% lib/app_web/views/layout_view.ex                3        0        0
100.0% lib/app_web/views/page_view.ex                  3        0        0
100.0% lib/app_web/views/sent_view.ex                  3        0        0
[TOTAL] 100.0%
----------------
```

We think it's _awesome_ that Phoenix creates tests
for all the functions generated by the `mix gen.html`. <br />
This is how software development should work!

With that checkpoint completed, let's move on to the _fun_ part!


### 5. Insert SNS Notification Data

The _magic_ of our **`email`** dashboard
is knowing the _status_ of each individual message
and the _aggregate_ statistics for _all_ messages.
Luckily AWS has already figured out the infrastructure part.

If you are unfamiliar with Amazon Simple Notification Service
([SNS](https://aws.amazon.com/sns/)),
it is a managed service that can send notifications to any other system.
In our case the only notifications we are interested in
are those that relate to the **`email`** messages
we have sent using AWS Simple Email Service (SES).


#### Requirements for `upsert_sent/1` Function


We need to create an `upsert_sent/1` function
in the `/lib/app/ctx.ex` file
that will handle any notification data
received from the Lambda function.
The point of an
[`UPSERT`](https://wiki.postgresql.org/wiki/UPSERT) function
is to **`insert`** or **`update`** a record. <br />
The `upsert_sent/1` function needs to do _three_ things: <br />

1. Check if the `payload` sent by the Lambda function
contains an email address. <br />
  **a.** `if` the `payload`  includes an `email` key,
  we attempt to find that `email` address
  in the **`people`** table by looking up the **`email_hash`**.
  `if` the **`person`** record does not exist for the given `email`,
  _create_ it and retain the `person_id`.
  With the `person_id`, **`upsert`** the **`sent`** item.

2. If the `payload` includes a `status` key,
look it up in the `status` table.
`if` the `status` exists,
use the `status.id`
as `status_id` for the `sent` record.
`if` the `status` does _not_ exist, create it.

3. If the `payload` does _not_ have an `email` key,
it should have a `message_id` key
which means this is an SNS notification. <br />
  **a.** Lookup the `message_id` in the **`sent`** table.
  `if` there is no record for the `message_id`, `create` it! <br />
  `if` the `sent` record exists, update it using the revised status.




#### 5.1 Create the First Test for `upsert_sent/1`


The SNS notification data _ingested_ from `aws-ses-lambda`
will be inserted/updated in the `sent` table
using the `upsert_sent/1` function.
The function does not _currently_ exist,
so let's start by creating a test for it.







##### 5.1.1 Create Bounce Fixture



`test/fixtures/bounce.json`














We are going invoke the `create_sent/1` function
in `lib/app/ctx.ex` to insert data into the `sent` table.








<br /><br /><br /><br />


### Why _Not_ Subscribe to the SNS/SES Notifications in Phoenix?

We _could_ configure AWS SNS
to send all SES related notifications
_directly_ to our **`email`** (_Phoenix_) App,
however that has a potential downside:
[DDOS](https://en.wikipedia.org/wiki/Denial-of-service_attack)
When we create an API endpoint
that allows inbound POST HTTP requests,
we need to consider _how_ it can (_will_) be _abused_.

In order to _check_ that an SNS
payload is _genuine_ we need to
retrieve a signing certificate from AWS
and cryptographically check if the **`Signature`** is valid.
This requires a GET HTTP Request to fetch the certificate
which takes around **200ms** for the round trip.

So rather than _subscribing_ directly to the notifications
in our **`email`** (_Phoenix_) App,
which would open us to DDOS attacks,
because of the additional HTTP Request,
we are doing the SNS parsing in our Lambda function
and securely sending the parsed data back to the Phoenix app.


<!--

### _Required_ Environment Variables

Running this app or its' tests on your local machine will require
that you set a few
[*environment variables*](https://github.com/dwyl/learn-environment-variables)

Using your terminal or text editor, create your `.env` file.  
Then *paste* this *sample* into your `.env` file:

```txt
JWT_SECRET=WhatEverYouWant
```







## Troubleshooting

-->
