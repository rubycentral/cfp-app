# CFP-App

This is a Ruby on Rails application that you can deploy to manage your conference's call for proposal (CFP) and program.  It was written by Ruby Central to run the CFPs for RailsConf and RubyConf.  We've open sourced it so other organizers can use it themselves.

The CFP app is not the conference website but just to place for potential speakers to submit talks for your CFP.  You'll end up pointing those interested in submitting a talk to your deployed version of this application.  From there speakers can submit their talk, track their talk's progress and update their profile and talk details as need be.  As an organizer you can have a group of reviewers that blindly look over proposals, give feedback, tag and rate them.  You can have a different group of organizers that then sift through talks, curate your program, send out acceptance emails and manage the program.  We'll get into the details of the specifics of all of these things below.

## Heroku

The app was written with a Heroku deployment stack in mind. You can easily deploy the application using the button below, or you can deploy it anywhere assuming you can run Ruby 2.1.2 and Rails 4.1.2 with a postgres database and an SMTP listener.

The Heroku stack will use the free SendGrid Starter and Heroku postgreSQL
addons.

[![Deploy to Heroku](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

Upon deploying to Heroku you will probably want to log in using Twitter or
GitHub and then run `heroku run console` to update the first Person object to
be an admin like this:


    ```bash
    p = Person.first
    p.admin = true
    p.save
    ```

Do make sure that the Person record you pull back is indeed your newly created user and the one that should get admin permissions!

## Setup
* Required Items

Make sure you have Ruby 2.1 and Postgres installed in your environment.  This is a Rails 4.1 app and uses bundler to install all required gems.  We are also making the assumption that you're familiar with how Rails apps and setup and deployed.  If this is not the case then you'll want to refer to documentation that will bridge any gaps in the instructions below.

1. Install gem requirements

    ```bash
    bundle install
    ```
    NOTE: You may need to install Qt/`qmake` to get Capybara to work; with
    Homebrew you can run `brew install qt`.

1. Duplicate and edit environment variables

    ```bash
    cp env-sample .env
    ```

    [Omniauth](http://intridea.github.io/omniauth/) is set up to use Twitter and Github for logins in production.  You'll want to put your own key and secret in for both.  Other environment variables will include your postgres user and Rails' secret_token.

1. Duplicate and edit database.yml

    ```bash
    cp config/database_example.yml config/database.yml
    ```

1. Build dev database

    ```bash
    bundle exec rake db:create db:migrate db:seed
    ```

    NOTE: Seed will make an admin user with an email of an@admin.com to get started.  There is a special, development only login method in Omniauth that you can use to test it out.

1. Start the server

    ```bash
    bundle exec rails server
    ```

### Environment variables

    TIMEZONE (defaults to Pacific if not set)
    POSTGRES_USER (dev/test only)
    MAIL_HOST (production only - from host)
    MAIL_FROM (production only - from address)
    SECRET_TOKEN (production only)
    GITHUB_KEY
    GITHUB_SECRET
    TWITTER_KEY
    TWITTER_SECRET

## Contributing

View our CONTRIBUTING.md file to see guidelines on how to make CFP App better.

## Contributors

The CFP App was initially authored by Ben Scofield.  Marty Haught took over the project and lead development for the CFP for RailsConf 2014.  Below are the others that participating on the project while it was a private project.

* Matt Garriott
* Andy Kappen
* Timothy King
* Ryan McDonald
* Scott Meade
* Sarah Mei

It was open sourced in May 2014 and moved to its new home.  Please view the contributor graph for those that have contributed since it was open sourced.
