# Cercle.co - Open Source CRM Phoenix Vuejs. 

Cercle.co stick to only one principle: Each contact is a Trello Card.

Easy & Visual to keep track of your sales, partnerships, support tickets, onboarding clients. 

[To test it, You can go here: http://www.cercle.co/register](http://www.cercle.co/register)


## To install Cercle on Local

You need to setup a postgresql DB version 9.5

1. Rename to dev.secret_example.exs to dev.secret.exs
2. Fill out the parameters
3. Run the migration
4. You're good to go!

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


