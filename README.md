# Cercle - World-Class Open Source CRM

Cercle is an open source CRM easy to use and inspired by Trello. No bullshit.

[To test it, You can go here http://www.cercle.co/register](http://www.cercle.co/register)

## To install Cercle on Local
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


