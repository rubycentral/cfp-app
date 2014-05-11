# CFP-App

### Overview
This is a Ruby on Rails application that can be deployed to manage a conference's call for proposal (CFP) and program. It was written by Ruby Central to run the CFPs for RailsConf and RubyConf. We've open sourced it so other organizers can use it themselves.

Features:
  -  blind proposal review process
  -  detailed analytics about the state of the CFP
  -  role specific interfaces for simplified reviewing and organizing
  -  control over every aspect of program creation
  -  robust schedule creation including multi room, multi track and multi day conferences
  -  program and schedule exports to JSON or CSV

CFP-app manages a CFP's complete life cycle from speaker CFP submission to program selection and scheduling for multi-day mulit-track conferences.

Speakers are guided through the process of proposal submission. Interaction between speakers and reviewers is anonymous in the case that further clarification is needed. Speakers can return to edit talk details or bio information and track their proposals process.

Reviewers have tools to browse proposals, tag, leave feedback where necessary and rate talks. Speakers and reviewers are notified of activities on proposals of interest by an in app notification system or email updates.

Organizers can perform all tasks of a reviewer in addition to managing reviewers, curating program, sending acceptance emails, and creating schedule. The final program and schedule can then be exported via JSON or CSV.

Other Features:
  -  anonymous speakers to reviewers messaging
  -  internal reviewer to reviewer messaging
  -  customizable email notification on proposal state change (acceptance, waitlisting or rejection)
  -  demographic recording
  -  multiple proposals per speaker
  -  management of multiple events
  -  persistent user profiles and proposals


The app was written with a Heroku deployment stack in mind. When using heroku a database and an email sending service are the only required addons. Any deploy should work assuming it can run Ruby 2.1 and Rails 4.1 with a postgres database and an SMTP listener.

## Setup
### Required Items

Make sure you have Ruby 2.1 and Postgres installed in your environment. This is a Rails 4.1 app and uses bundler to install all required gems. We are also making the assumption that you're familiar with how Rails apps and setup and deployed. If this is not the case then you'll want to refer to documentation that will bridge any gaps in the instructions below.

### Install gem requirements

    bundle install

### Duplicate and edit environment variables

    cp env-sample .env

[Omniauth](http://intridea.github.io/omniauth/) is set up to use Twitter and Github for logins in production. You'll want to put your own key and secret in for both. Other environment variables will include your postgres user and Rails' secret_token.

### Duplicate and edit database.yml

    cp config/database_example.yml config/database.yml


### Build dev database

    bundle exec rake db:create db:migrate db:seed

NOTE: Seed will make an admin user with an email of an@admin.com to get started. There is a special, development only login method in Omniauth that you can use to test it out. We'll discuss production setup separately.

### Environment variables
    POSTGRES_USER (dev/test only)
    MAIL_HOST (production only)
    GITHUB_KEY
    GITHUB_SECRET
    SECRET_TOKEN
    TWITTER_KEY
    TWITTER_SECRET

## Contributing

View our CONTRIBUTING.md file to see guidelines on how to make CFP App better.

## Contributors

The CFP App was initially authored by Ben Scofield. Marty Haught took over the project and lead development for the CFP for RailsConf 2014. Below are the others that participating on the project while it was a private project.

-  Matt Garriott
-  Andy Kappen
-  Timothy King
-  Ryan McDonald
-  Scott Meade
-  Sarah Mei

It was open sourced in May 2014 and moved to its new home. Please view the contributor graph for those that have contributed since it was open sourced.
