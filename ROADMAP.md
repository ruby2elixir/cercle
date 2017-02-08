Usefull Command
mix
mix ecto.gen.migration add_posts_table

# Cercle CRM OPEN SOURCE ROADMAP

--------- field data in contacts & organizations in a JSONB Field om Postgresql DB------

Requirement for the name of each field

APPNAME/NAMEOFTHEFIELD

:data => %{"cercle/full_name" => "John Doe", etc ...}

data could contain 
-> string
-> integer
-> Datetime  |  integer with UnixTimeStamp , field will be with the extension field_at


BEFORE RELEASE ON PRODUCTION

Antoine work
-> Improve Authentifiction
-> migration data

v1 : BIG BANG RELEASE : OPEN SOURCE RELEASE Abhijeet Team work
-------------------
------------------
-> Remove the references VAR sur le git
-> display 10 last notifications
-> Basic Paginations for Contacts / Companies Index page
-> being able CSV Import to contacts
-> One click install on Heroku
-> review code
-> Remove delete_all callback for contact when we delete a company
-> Multi contact per deal

v1.1 : HELLO WORD RELEASE : ADD-ON, THIRD PARTIES SYSTEM
-------------------
-> meta_data in company table (list )
-> multi company
--> BBC email proxy





--------------------------------------------------------


POTENTION NEW FEATURES
-> Creation d'un nouveau champs d'updater timeline
-> Add Bulk Action : Assign, Edit , Delete
-> Reminder for Contact
-> Improve the notification feature
-> Notification Tab
-> Search Contact from Contact Index.
-> Pagination
-> Contact EDIT all AJAX + edit/delete post on timeline
-> warehouse integration Lydi, Segment, Hull.io
-> Marketplace
-> TimelineEvent integration
-> Action from Contact Page
-> Add Menu from Cercle
-> Import / Export Contact //  Company
