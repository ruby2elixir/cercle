# Cercle CRM - A visual & simple CRM to manage contacts & projects - Phoenix & Vuejs 

Cercle is a CRM for smart people who need to manage a database of contacts and get things done.

Easy to keep track of your sales, partnerships, support tickets, onboarding clients. 

[Try Cercle Today. Click here: http://www.cercle.co/register](http://www.cercle.co/register)

## Why Cercle?
- realtime
- visual like Trello
- simple
- API ready
- open source
- free

## Features
- Each Card can be linked to several contacts
- Card Contact Tags
- Card Contact Organization
- Card Attachements
- Card Tasks (with optional due date)
- Card Comments
- Card Email Notification System for team member
- Import CSV
- Export CSV 
- Board Timeline on a sidebar
- Board Archive/Unarchive
- Oauth for API in Zapier


## Changelog

### V1.2 - September 2017
#### New Features
- Multi Company (User can switch between several companies)
- URL are now clickable in description
- Minor Bug Fixes
- Improvement of the test suite

### V1.1 - August 2017

- UX improvements so we can use Card without contacts
- Notification system for task due date & Card due date

### V1.0 - June 2017
- Oauth Integration with Zapier
- Add Full name option during CSV Import

## To use Cercle CRM API

- make sure to include into your header: authorization Bearer TOKEN_FOUND_IN_YOUR_SETTINGS
- you can get the list of boards, contacts by using the API like
  - /api/v2/company/:id_of_your_company/board
  - /api/v2/company/:id_of_your_company/contact
- you can create or edit board, card also.

More Documentation about API is coming soon.

## To install Cercle on Local

You need to setup a postgresql DB version 9.5

1. Rename the file dev.secret_example.exs to dev.secret.exs
2. Fill out the parameters of dev.secret.exs
3. mix ecto.create (Create the DB)
4. mix ecto.migrate (Run the migration)
5. mix phoenix.server (You're good to go!)

## To Install Cercle into heroku
1. mix phoenix.gen.secret
2. heroku config:set SECRET_KEY_BASE="your_key_here"
3. heroku config:set POOL_SIZE=18
4. add others parameters from dev.secret into Heroku config:set
5. You're good to go!

## Using Docker For Development
1. Given you already have docker and docker-compose installed on your machine, Simply run these following commands:
```
# Build all and pull images and containers
docker-compose build
# Build application dependencies.
# This will set permission to allow our build script to run.
chmod +x build
./build
# Build the Docker image and start the `web` container, daemonized
docker-compose up -d web
```

## Contribution
Feel free to send your PR with proposals, improvements or corrections!

## License
Copyright © 2016-2017 AK Cercle Inc.

Licence LGPL v3.


