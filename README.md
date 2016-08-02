# CFP-App 2.0

## WARNING

This is a major upgrade from the original CFP App that is not backwards compatible.  We are in the process of rewriting many of the core data models and changing how the app works.

Do not switch to this fork until further notice. We are not providing a migration path for your existing data at this time. Once this fork becomes stable we'll explore if migrating legacy cfp app databases to the new version makes sense.  Please reach out to Marty Haught if you have any questions.

## Overview

This is a Ruby on Rails application that lets you manage your conference's call for proposal (CFP), program and schedule.  It was written by Ruby Central to run the CFPs for RailsConf and RubyConf.

The CFP App does not provide a public facing website for your conference, though we have a sister project that does integration with the CFP App's export data to give you a starting place for your website.

At a high level the CFP App allows speakers to submit and manage their proposals for your event.  Organizers can create a group of reviewers that blindly review and rate talks.  Organizers can then select talks to be accepted into the program including a waitlist of proposals.  Finally organizers can create a schedule and slot confirmed talks.  Down below, I'll give a detailed description of the features and workflows of the CFP App under the section 'How to use the CFP App'

## Getting Started

Make sure you have Ruby 2.3 and Postgres installed in your environment.  This is a Rails 4.2 app and uses bundler to install all required gems.  We are also making the assumption that you're familiar with how Rails apps and setup and deployed.  If this is not the case then you'll want to refer to documentation that will bridge any gaps in the instructions below.

Run [bin/setup](bin/setup) script to install gem dependencies and setup database for development.

```bash
bin/setup
```

This will create `.env`, a development database with seed data. Seed will make an admin user with an email of `an@admin.com` to get started. There is a special, development only login method in Omniauth that you can use to test it out.

NOTE: You may need to install Qt/`qmake` to get Capybara to work; with Homebrew you can run `brew install qt`.

Start the server:

```bash
bin/rails server
```

If you have the heroku toolbelt installed you can also use:

```bash
heroku local
```

This will boot up using Foreman and allow the .env file to be read / set for use locally. Runs on port 5000.

### Environment variables

[Omniauth](http://intridea.github.io/omniauth/) is set up to use Twitter and Github for logins in production. You'll want to put your own key and secret in for both. Other environment variables will include your postgres user and Rails' secret\_token.

    TIMEZONE (defaults to Pacific if not set)
    POSTGRES_USER (dev/test only)
    MAIL_HOST (production only - from host)
    MAIL_FROM (production only - from address)
    SECRET_TOKEN (production only)
    GITHUB_KEY
    GITHUB_SECRET
    TWITTER_KEY
    TWITTER_SECRET

### User roles

There are five user roles in CFP App. To log in as a user type in development mode, locate the email for each user in `seeds.rb`. The password is the same for each user, and is assigned to the variable `pwd` in the seed file.

- **Admin:**
  - Edit/delete users
  - Add/archive events
  - Automatically an **Organizer** for created events
- **Organizer:**
  - Edit/view event pages: event dashboard, program, schedule
  - View event proposals
- **Track Director:**
  - TBD
- **Reviewer:**
  - View/rate anonymous event proposals for an event
  - Cannot rate own proposals
- **Speaker:**
  - View/edit/delete own proposals

## Deployment on Heroku

The app was written with a Heroku deployment stack in mind. You can easily deploy the application using the button below, or you can deploy it anywhere assuming you can run Ruby 2.3.0 and Rails 4.2.5 with a postgres database and an SMTP listener.

The Heroku stack will use the free SendGrid Starter and Heroku postgreSQL
addons.

[![Deploy to Heroku](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

Upon deploying to Heroku you will probably want to log in using Twitter or
GitHub and then run `heroku run console` to update the first User object to
be an admin like this:

```bash
user = User.first
user.admin = true
user.save
```

Do make sure that the User record you pull back is indeed your newly created user and the one that should get admin permissions!

## How to use the CFP App

### Creating your event

You must login as an admin to create an event.  As touched on above in the deploy section you will want to either login to the app or work directly in the console.  Find your User record or create a new one.  I do recommend you create the admin via login and then find the record via console since the User record uses Services for authentication.  Once you find your record assign true to the admin attribute such as this:

```bash
p = User.first
p.admin = true
p.save
```

One note, in development mode you have a special testing login called 'developer'.  With this you can login and seed a new User record by entering name and email. Very handy for testing things locally.

One logged in you should see your user's name with a dropdown arrow in the top right of the nav bar.  In that dropdown click on the 'Manage Events' link.  The Events page will show you all events on the system, which should be blank initially.  Click 'Add Event' to create your event.  Ideally you can fill out all this information though only name and contact email are required.

### Managing your event

Once done you should land on your event's organizers page.  This is the hub of managing your event.  I will briefly touch on the things you can do here.

1. You will likely want to add other organizers and reviewers to the event.  This is at the bottom of the page in a section called 'Participants'.  Click 'Add/Invite New Participant' to add them.  You will use their email address to get them added.  The system will add any existing users if their email address matches the invite.  You can fully manage who has access to your event in that section.

2. The next order of business will be to draft up your conference guidelines via the 'Edit Guidelines' button.  Guidelines are the instructions speakers see before submitting a proposal.  This is where you give them any information and instructions before they submit a talk. You can preview the guidelines with a link to the public guidelines page after they've been set.

3. 'Edit Tags' will keep a list of tags that can be used by speakers (proposal tags) and by reviewers (review tags).  Above the 'Edit Tags' button is the list of both tag groups.  Speakers and Reviewers can only tag their proposals from these choices.

4. 'Edit Event' allows you to change any of the details you initially set when creating the event.  If you didn't set the opening and closing dates on your event, you can do that under 'CFP Dates'.  Additionally, you will want to indicate the dates for your conference under 'Event Dates'.  These dates are required to create a schedule.  Finally, the status of the CFP, such as open or closed, is listed under 'State'.  It must be in the open state to accept proposals.  If you need to delete your event, you can do it on the edit page.

5. 'Edit Speaker Notifications' allows you to craft the email content that goes out to speakers when their talks are accepted, waitlisted or rejected. The app does have defaults but we recommend you draft your own email bodies.  On the right side there is a markup legend with some custom tags for making the emails dynamic such as including proposal title and confirmation link.

### Navigation

The nav bar has several parts to it.  On the far left we have the 'CFPApp' link which takes you to a public-facing events page.  There you would see all events active on the site.

Next to the right is the 'Speaking' dropdown. All users get this and from there you can navigate to your proposals.  That page has links to each proposal you have submitted to all events as well as any speaker invitations you may have received.  We'll touch on speaker invitations under 'Submitting a Proposal'.

If you have Reviewer access you will see a 'Review' dropdown next to the right. Each event you have reviewer access to will show up there, which takes you to the proposals page.  We will talk about that in detail under 'Reviewing Proposals'

If you have Organizer access you will see an 'Organize' dropdown will give you three links per event you have organizer access to: Proposal, Program and Schedule.  We cover each of these in the Organizer section.

The 'Notifications' dropdown will display a count of any in app notifications you haven't read.  Clicking the dropdown will show you a list of these notifications such as 'Marty Haught has commented on <talk title>'.  You have a 'Mark all as read' and 'View all notifications' options as well.

We briefly touched on the user dropdown on the far right. This is visible to all users.  From there they can sign out or visit their profile.  Their profile is how they edit their name, email or bio, allow them to connect to various services such as Github or Twitter.  If you are an admin, you will also have a Users link.  This is where you manage all User records.

### Submitting a Proposal

The primary way to submit a talk is to visit the public guidelines page and click 'Submit a proposal' to get started.  This does require the event's CFP to be open.

The heart of the proposal is the title and abstract.  These two will show up in your program and schedule.  They are required fields and have limits on how long they can be.  The details field is for reviewers/organizers only and is there to allow the speaker to show 'what's behind the curtain' like an outline or other explanations that don't belong in the abstract.  The pitch is there to allow the speaker to sell you on why this talk should be in your event.

On the right column there is a section for the speaker to select what tags they feel are appropriate, assuming your event is using tags.  Next it will show the speaker's name, email and bio.  The bio can be modified per proposal in case the speaker wants to tweak the bio to sound better for the specific topic.  Name, email and bio are hidden from reviewers and only visible to organizers at a later stage of the CFP.

Finally there is a preview on the bottom right of the page.  Assuming everything looks good go ahead and hit 'Submit Proposal' at the bottom right.

You can get back to your proposal by going to the 'My Proposals' link under 'Speaking' nav dropdown.  You will be able to see its status, which should be 'submitted' until either you withdraw the talk or the organizers make a decision on your talk.

Returning to your proposal page, you will see both an 'Edit' and either 'Delete Proposal' or 'Withdraw' button.  If you need to make edits, feel free to do so up until the organizers have decided if your talk is in or out. Once it has been accepted or waitlisted, you cannot edit the proposal.  At that point you reach out directly to the organizers to edit it.  We did this on purpose so talks can't be changed without organizer awareness and permission.

Another feature on the proposal page is the ability to invite additional speakers.  If your talk has more than one speaker, you would now invite them via their email to your talk.  They will get an email with instructions on how to accept your invitation. This is important so that their information will be associated with the talk.

Additionally, you can make comments to the reviewers on your talk.  You will remain anonymous, identified only as 'speaker', though any replies from the reviewers will indicate which reviewer made the comment.

You can see how many reviews your talk has received but not details on what sort of rating it received.  Finally, you can see if your talk status has changed from 'submitted'.


### Reviewing Proposals

As a reviewer or organizer, you will use the 'Review' dropdown to get to the proposals page for your event. It is the hub for going through and rating all the proposals submitted.  It has a Statistics section up top where it will show you how many proposals you have rated versus how many have been submitted.  Below that is a count of how many unrated proposals are left.

The list of proposals can be filtered and sorted as you see fit.  This is very important so that you can either focus on a certain tag or look at the oldest proposals that you have not rated.  The list shows the following fields:

  - Score: the average score across all ratings
  - Your Score: how you rated the proposal
  - Ratings: how many ratings total a talk has received
  - Title: which is also the link to view the proposal
  - Proposal Tags: the tags the speaker(s) associated with the proposal
  - Reviewer Tags: the tags the reviewers have added
  - Comments:  a total count of public comments including reviewers and speakers
  - Submitted On: the original submission date and time
  - Updated At: The last time the speaker updated the proposal

The sort order is sticky and you can use the shift key to sort by more than one column.  Use the 'Reset Sort Order' button to clear this out.

By clicking the proposal title you can view the proposal details page.  Here you can see the title, abstract, details and pitch fields for the talk. If any comments have been made, you can view those as well as make a comment yourself.  The Review column on the far right is only visible to other reviewers and organizers.  You will not be able to see any other ratings or internal comments until you have rated the talk.  This is to keep the reviewer from being biased by what others have said on their reviews.  You can set or modify review tags at any point and this again is visible only to other reviewers.

The rating scale is 1 through 5.  At RubyCentral we consider a 1 as a strong no, 2 is a likely not, 3 is a good talk and certainly in the running, 4 is a great talk and a fit for the event and 5 as a top notch and ideal talk for the event.  We also like to get at least three ratings for each talk, preferrably more.  Once you have rated the talk you will see an average rating along with the other ratings the proposal received.

Finally internal comments can be viewed below, once you have rated the talk.  These comments will only be visible to fellow reviewers and is a place for any commentary that can help determine how suitable the talk is for your event without the speaker seeing the discussion.

One note, at this point updating the review tags or posting a comment in either comment box will refresh the page and lose changes in the other comment box.  Only Rating is an ajax call that will not disturb the rest of the page.

One thing that will happen is you will get notifications showing you what talks have been updated after this point.  You only get notifications for talks you have reviewed though.  We added a flag in the participants sections which defaults to true for reviewers to receive an email when comments have been left on the talk.  You will not receive an email for an update though notifications for updates do appear in the Notifications nav list.

### Organizing Duties

...Coming Soon...



## Customizing and Contributing

It is likely you may want to customize or change how the CFP App works.  Feel free to fork and modify as you see it, as long as you respect the MIT license.  If you feel any of your customizations are appropriate to contribute back to the project, please review our CONTRIBUTING.md file to see the guidelines on how to work with us to make the CFP App better.


## Contributors

The CFP App was initially authored by Ben Scofield.  Marty Haught took over the project and lead development for the CFP for RailsConf 2014.  Below are the others that participated on the project while it was a private project.

* Matt Garriott
* Andy Kappen
* Timothy King
* Ryan McDonald
* Scott Meade
* Sarah Mei

It was open sourced in May 2014 and moved to its new home.  Please view the contributor graph for those that have contributed since it was open sourced.
