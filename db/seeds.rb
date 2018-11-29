def run
  perform_deliveries_orig = ActionMailer::Base.perform_deliveries

  begin
    # Disable sending emails during seeding.
    ActionMailer::Base.perform_deliveries = false
    puts "Mail delivery disabled" if perform_deliveries_orig

    puts "Creating seed data..."
    create_seed_data
    puts "Seeding complete."

  rescue => e
    puts "Seeding halted! Error: " + e

  ensure
    ActionMailer::Base.perform_deliveries = perform_deliveries_orig
    puts "Mail delivery reenabled" if perform_deliveries_orig
  end

end

def create_seed_data

  pwd = "userpass"

  ## Users
  admin            = User.create(name: "Admin", email: "an@admin.com", admin: true, password: pwd, password_confirmation: pwd, confirmed_at: Time.now)
  organizer        = User.create(name: "Event MC", email: "mc@seed.event", password: pwd, password_confirmation: pwd, confirmed_at: Time.now)
  track_director   = User.create(name: "Track Director", email: "track@seed.event", password: pwd, password_confirmation: pwd, confirmed_at: Time.now)
  reviewer         = User.create(name: "Reviewer", email: "review@seed.event", password: pwd, password_confirmation: pwd, confirmed_at: Time.now)
  speaker_reviewer = User.create(name: "Speak and Review", email: "both@seed.event", password: pwd, password_confirmation: pwd, confirmed_at: Time.now)
  speaker_1        = User.create(name: "Jenny Talksalot", email: "speak1@seed.event", password: pwd, password_confirmation: pwd, confirmed_at: Time.now)
  speaker_2        = User.create(name: "Pamela Speakerson", email: "speak2@seed.event", password: pwd, password_confirmation: pwd, confirmed_at: Time.now)
  speaker_3        = User.create(name: "Jim Talksman", email: "speak3@seed.event", password: pwd, password_confirmation: pwd, confirmed_at: Time.now)
  speaker_4        = User.create(name: "Mark Speaksmith", email: "speak4@seed.event", password: pwd, password_confirmation: pwd, confirmed_at: Time.now)
  speaker_5        = User.create(name: "Erin McTalky", email: "speak5@seed.event", password: pwd, password_confirmation: pwd, confirmed_at: Time.now)

  ### SeedConf -- event is in the middle of the CFP
  seed_start_date = 8.months.from_now

  # Core Event Info
  seed_guidelines = %Q[
# SeedConf wants you!

The first annual conference about seed data is happening
in sunny Phoenix, Arizona on December 1st, 2016!

If your talk is about seed data in Rails apps, we want to hear about it!

## #{Faker::Hipster.sentence(4)}
#{Faker::Hipster.paragraph(8)}

#{Faker::Hipster.paragraph(13)}

#{Faker::Hipster.paragraph(6)}
]

  seed_event = Event.create(name: "SeedConf",
                            slug: "seedconf",
                            url: Faker::Internet.url,
                            contact_email: "info@seed.event",
                            closes_at: 6.months.from_now,
                            state: "open",
                            start_date: seed_start_date,
                            end_date: seed_start_date + 2.days,
                            guidelines: seed_guidelines,
                            proposal_tags: %w(beginner intermediate advanced),
                            review_tags: %w(beginner intermediate advanced))

  # Session Formats
  lightning_talk   = seed_event.public_session_formats.create(name: "Lightning Talk", duration: 5, description: "Warp speed! Leave your audience breathless and thirsty for more.")
  short_session    = seed_event.public_session_formats.create(name: "Short Talk", duration: 40, description: "Kinda short! Talk fast. Talk hard.")
  long_session     = seed_event.public_session_formats.create(name: "Long Talk", duration: 120, description: "Longer talk allows a speaker put more space in between words, hand motions.")
  internal_session = seed_event.session_formats.create(name: "Beenote", public: false, duration: 180, description: "Involves live bees.")

  # Tracks
  track_1 = seed_event.tracks.create(name: "Best Track", description: "Better than all the other tracks.", guidelines: "Watch yourself. Watch everybody else. All of us are winners in the best track.")
  track_2 = seed_event.tracks.create(name: "OK Track", description: "This track is okay.", guidelines: "Mediocrity breeds mediocrity. Let's talk about how to transcend the status quo.")
  track_3 = seed_event.tracks.create(name: "Boring Track", description: "Great if you want a nap!", guidelines: "Sleep deprivation is linked to many health problem. Get healthy here so you can be 100% for the Best Track.")

  # Rooms
  sun_room = seed_event.rooms.create(name: "Sun Room", room_number: "SUN", level: "12", address: "123 Universe Drive", capacity: 300)
  moon_room = seed_event.rooms.create(name: "Moon Room", room_number: "MOON", level: "6", address: "123 Universe Drive", capacity: 150)
  seed_event.rooms.create(name: "Venus Theater", room_number: "VEN-T", level: "2", address: "123 Universe Drive", capacity: 75)

  # Event Team
  seed_event.teammates.create(
    user: admin,
    email: admin.email,
    role: "organizer",
    mention_name: "admin",
    state: Teammate::ACCEPTED
  )
  seed_event.teammates.create(
    user: organizer,
    email: organizer.email,
    role: "organizer",
    mention_name: "organizer",
    state: Teammate::ACCEPTED
  )
  seed_event.teammates.create(
    user: track_director,
    email: track_director.email,
    role: "program team",
    mention_name: "track_director",
    state: Teammate::ACCEPTED
  )
  seed_event.teammates.create(user: reviewer,
    email: reviewer.email,
    role: "reviewer",
    mention_name: "reviewer",
    state: Teammate::ACCEPTED
  )
  seed_event.teammates.create(user: speaker_reviewer,
    email: speaker_reviewer.email,
    role: "reviewer",
    state: Teammate::ACCEPTED
  ) # can't be mentioned

  # Proposals - there are no proposals that are either fully "accepted" or offically "not accepted"
  submitted_proposal_1 = seed_event.proposals.create(event: seed_event,
                                                     uuid: "abc123",
                                                     title: Faker::Superhero.name,
                                                     abstract: Faker::Hipster.sentence,
                                                     details: Faker::Hacker.say_something_smart,
                                                     pitch: Faker::Superhero.power,
                                                     session_format: long_session,
                                                     track: track_1)

  submitted_proposal_2 = seed_event.proposals.create(event: seed_event,
                                                     uuid: "def456",
                                                     title: Faker::Superhero.name,
                                                     abstract: Faker::Hipster.sentence,
                                                     details: Faker::Hacker.say_something_smart,
                                                     pitch: Faker::Superhero.power,
                                                     session_format: long_session,
                                                     track: track_2)

  soft_waitlisted_proposal = seed_event.proposals.create(event: seed_event,
                                                         state: "soft waitlisted",
                                                         uuid: "jkl012",
                                                         title: Faker::Superhero.name,
                                                         abstract: Faker::Hipster.sentence,
                                                         details: Faker::Hacker.say_something_smart,
                                                         pitch: Faker::Superhero.power,
                                                         session_format: short_session,
                                                         track: track_3)

  soft_accepted_proposal = seed_event.proposals.create(event: seed_event,
                                                       state: "soft accepted",
                                                       uuid: "mno345",
                                                       title: Faker::Superhero.name,
                                                       abstract: Faker::Hipster.sentence,
                                                       details: Faker::Hacker.say_something_smart,
                                                       pitch: Faker::Superhero.power,
                                                       session_format: internal_session,
                                                       track: track_1)

  soft_rejected_proposal = seed_event.proposals.create(event: seed_event,
                                                       state: "soft rejected",
                                                       uuid: "xyz999",
                                                       title: Faker::Superhero.name,
                                                       abstract: Faker::Hipster.sentence,
                                                       details: Faker::Hacker.say_something_smart,
                                                       pitch: Faker::Superhero.power,
                                                       session_format: short_session,
                                                       track: track_2)

  withdrawn_proposal = seed_event.proposals.create(event: seed_event,
                                                   state: "withdrawn",
                                                   uuid: "pqr678",
                                                   title: Faker::Superhero.name,
                                                   abstract: Faker::Hipster.sentence,
                                                   details: Faker::Hacker.say_something_smart,
                                                   pitch: Faker::Superhero.power,
                                                   session_format: lightning_talk,
                                                   track: track_1)

  # Speakers
  submitted_proposal_1.speakers.create(speaker_name: speaker_1.name, speaker_email: speaker_1.email, bio: "I am a speaker for cool events!", user: speaker_1, event: seed_event)
  submitted_proposal_1.speakers.create(speaker_name: speaker_2.name, speaker_email: speaker_2.email, bio: "I know a little bit about everything.", user: speaker_2, event: seed_event)
  submitted_proposal_2.speakers.create(speaker_name: speaker_2.name, speaker_email: speaker_2.email, bio: "I know a little bit about everything.", user: speaker_2, event: seed_event)
  soft_accepted_proposal.speakers.create(speaker_name: speaker_3.name, speaker_email: speaker_3.email, bio: "I am the best speaker in the entire world!", user: speaker_3, event: seed_event)
  soft_waitlisted_proposal.speakers.create(speaker_name: speaker_4.name, speaker_email: speaker_4.email, bio: "I specialize in teaching cutting edge programming techniques to beginners.", user: speaker_4, event: seed_event)
  soft_rejected_proposal.speakers.create(speaker_name: speaker_5.name, speaker_email: speaker_5.email, bio: "I like cookies and rainbows.", user: speaker_5, event: seed_event)
  withdrawn_proposal.speakers.create(speaker_name: speaker_3.name, speaker_email: speaker_3.email, bio: "I am the best speaker in the entire world!", user: speaker_3, event: seed_event)

  # Proposal Tags
  submitted_proposal_1.taggings.create(tag: "intermediate")
  submitted_proposal_2.taggings.create(tag: "intermediate")
  soft_waitlisted_proposal.taggings.create(tag: "beginner")
  soft_accepted_proposal.taggings.create(tag: "beginner")
  soft_rejected_proposal.taggings.create(tag: "beginner")
  withdrawn_proposal.taggings.create(tag: "advanced")

  # Reviewer Tags
  submitted_proposal_1.taggings.create(tag: "beginner", internal: true)
  submitted_proposal_2.taggings.create(tag: "beginner", internal: true)
  soft_waitlisted_proposal.taggings.create(tag: "beginner", internal: true)
  soft_accepted_proposal.taggings.create(tag: "beginner", internal: true)
  soft_rejected_proposal.taggings.create(tag: "intermediate", internal: true)
  withdrawn_proposal.taggings.create(tag: "advanced", internal: true)

  # Ratings
  submitted_proposal_1.ratings.create(user: organizer, score: 4)
  submitted_proposal_1.ratings.create(user: reviewer, score: 3)
  submitted_proposal_1.ratings.create(user: track_director, score: 5)

  submitted_proposal_2.ratings.create(user: organizer, score: 4)
  submitted_proposal_2.ratings.create(user: speaker_reviewer, score: 2)

  soft_waitlisted_proposal.ratings.create(user: track_director, score: 3)
  soft_waitlisted_proposal.ratings.create(user: organizer, score: 3)

  soft_accepted_proposal.ratings.create(user: organizer, score: 4)
  soft_accepted_proposal.ratings.create(user: reviewer, score: 3)
  soft_accepted_proposal.ratings.create(user: track_director, score: 4)
  soft_accepted_proposal.ratings.create(user: speaker_reviewer, score: 5)

  soft_rejected_proposal.ratings.create(user: organizer, score: 1)
  soft_rejected_proposal.ratings.create(user: reviewer, score: 3)
  soft_rejected_proposal.ratings.create(user: track_director, score: 1)
  soft_rejected_proposal.ratings.create(user: speaker_reviewer, score: 2)

  withdrawn_proposal.ratings.create(user: organizer, score: 5)
  withdrawn_proposal.ratings.create(user: reviewer, score: 5)
  withdrawn_proposal.ratings.create(user: speaker_reviewer, score: 4)

  # Comments
  organizer.comments.create(proposal: submitted_proposal_1,
                            body: "This looks great - very informative. Great job!",
                            type: "PublicComment")

  reviewer.comments.create(proposal: soft_accepted_proposal,
                           body: "Oh my goodness, this looks so fun!",
                           type: "PublicComment")

  track_director.comments.create(proposal: soft_accepted_proposal,
                                 body: "Cleary we should accept this talk.",
                                 type: "InternalComment")

  speaker_reviewer.comments.create(proposal: withdrawn_proposal,
                                   body: "Uhhhh... is this for real? I can't decide if this is amazing or insane.",
                                   type: "InternalComment")

  # Program Sessions
  accepted_proposal_1 = seed_event.proposals.create(event: seed_event,
                                                    uuid: "xoxoxo",
                                                    state: "accepted",
                                                    title: Faker::Superhero.name,
                                                    abstract: Faker::Hipster.sentence,
                                                    details: Faker::Hacker.say_something_smart,
                                                    pitch: Faker::Superhero.power,
                                                    session_format: long_session,
                                                    track: track_1,
                                                    confirmed_at: Time.current)

  accepted_proposal_2 = seed_event.proposals.create(event: seed_event,
                                                    uuid: "oxoxox",
                                                    state: "accepted",
                                                    title: Faker::Superhero.name,
                                                    abstract: Faker::Hipster.sentence,
                                                    details: Faker::Hacker.say_something_smart,
                                                    pitch: Faker::Superhero.power,
                                                    session_format: long_session,
                                                    track: track_3,
                                                    confirmed_at: Time.current)

  program_session_1 = seed_event.program_sessions.create(event: seed_event,
                                                         proposal: accepted_proposal_1,
                                                         state: ProgramSession::LIVE,
                                                         title: accepted_proposal_1.title,
                                                         abstract: accepted_proposal_1.abstract,
                                                         track: accepted_proposal_1.track,
                                                         session_format: accepted_proposal_1.session_format)

  program_session_2 = seed_event.program_sessions.create(event: seed_event,
                                                         proposal: accepted_proposal_2,
                                                         state: ProgramSession::LIVE,
                                                         title: accepted_proposal_2.title,
                                                         abstract: accepted_proposal_2.abstract,
                                                         track: accepted_proposal_2.track,
                                                         session_format: accepted_proposal_2.session_format)

  program_session_3 = seed_event.program_sessions.create(event: seed_event,
                                                         state: ProgramSession::LIVE,
                                                         title: "Keynote Session",
                                                         abstract: "The keynote session will kick off the conference for all attendees.",
                                                         session_format: internal_session)

  accepted_proposal_1.speakers.create(speaker_name: speaker_4.name, speaker_email: speaker_4.email, bio: "Experiential foodtruck consectetur thinker-maker-doer agile irure thought leader tempor thought leader. SpaceTeam commodo nulla personas sit in mollit iterate workflow dolore food-truck incididunt. In veniam eu sunt esse dolore sunt cortado anim anim. Lorem do experiential prototype velit workflow thinker-maker-doer 360 campaign thinker-maker-doer deserunt quis non.", user: speaker_4, program_session: program_session_1, event: seed_event)
  accepted_proposal_1.speakers.create(speaker_name: speaker_5.name, speaker_email: speaker_5.email, bio: "Prototype irure cortado consectetur driven laboru in. Bootstrapping physical computing lorem in Duis viral piverate incididunt anim. Aute SpaceTeam ullamco earned media experiential aliqua moleskine fugiat physical computing.", user: speaker_5, program_session: program_session_1, event: seed_event)
  accepted_proposal_2.speakers.create(speaker_name: speaker_2.name, speaker_email: speaker_2.email, bio: "Id fugiat ex dolor personas in ipsum actionable insight grok actionable insight amet non adipisicing. In irure pair programming sed id food-truck consequat officia reprehenderit in engaging thinker-maker-doer. Experiential irure moleskine sunt quis ideate thought leader paradigm hacker Steve Jobs. Unicorn ea Duis integrate culpa ut voluptate workflow reprehenderit officia prototype intuitive ideate.", user: speaker_2, program_session: program_session_2, event: seed_event)

  #Time Slots

  time_slot_1 = seed_event.time_slots.create({
    program_session: program_session_1,
    conference_day: 1,
    room: sun_room,
    start_time: "09:00",
    end_time:  "10:00",
    track: program_session_1.track
  })

  time_slot_2 = seed_event.time_slots.create({
    program_session: program_session_2,
    conference_day: 2,
    room: moon_room,
    start_time: "13:00",
    end_time: "14:00",
    track: program_session_2.track
  })

  empty_slot = seed_event.time_slots.build({
    room: sun_room,
    conference_day: 3,
    start_time: "12:00",
    end_time: "13:00",
    title: "",
    description: "",
    presenter: "",
  })

  empty_slot.save(validate: false)

  ### SapphireConf -- this is an event in the early set-up/draft stage
  sapphire_start_date = 10.months.from_now
  pwd = "userpass"

  # Core Event Info
  sapphire_guidelines = %Q[
# SapphireConf - The place to be in 2017!

The first annual conference about the hot new programming language Sapphire
is happening in moody Reykjavík, Iceland on February 1st, 2017!

If you are on the cutting edge with savvy Sapphire skills, we want you!

## #{Faker::Hipster.sentence(4)}
#{Faker::Hipster.paragraph(20)}
]

  sapphire_event = Event.create(name: "SapphireConf",
                                slug: "sapphireconf",
                                url: Faker::Internet.url,
                                contact_email: "info@sapphire.event",
                                start_date: sapphire_start_date,
                                end_date: sapphire_start_date + 1,
                                guidelines: sapphire_guidelines,
                                proposal_tags: %w(beginner intermediate advanced),
                                review_tags: %w(beginner intermediate advanced))

  # Event Team
  sapphire_event.teammates.create(user: admin, email: admin.email, role: "organizer", state: Teammate::ACCEPTED)
  sapphire_event.teammates.create(user: organizer, email: organizer.email, role: "organizer", state: Teammate::ACCEPTED)

  ### ScheduleConf -- this is an event that is ready to be scheduled
  schedule_conf_open_date = Date.yesterday
  pwd = "userpass"

  # Core Event Info
  schedule_guidelines = %Q[
# SheduleConf - The place to be in 2017!

The first annual conference about Sheduling an event
is happening in lovely Dayton, Ohio on March 1st, 2017!

If you are on the cutting edge with savvy scheduling skills, we want you!

## #{Faker::Hipster.sentence(4)}
#{Faker::Hipster.paragraph(20)}
]

  schedule_event = Event.create(name: "ScheduleConf",
                                slug: "scheduleconf",
                                url: Faker::Internet.url,
                                contact_email: "info@sschedule.event",
                                opens_at: schedule_conf_open_date,
                                closes_at: schedule_conf_open_date + 1.days,
                                start_date: schedule_conf_open_date + 10.days,
                                end_date: schedule_conf_open_date + 12.days,
                                guidelines: schedule_guidelines,
                                proposal_tags: %w(beginner intermediate advanced),
                                review_tags: %w(beginner intermediate advanced))

  # Event Team
  schedule_event.teammates.create(user: admin, email: admin.email, role: "organizer", state: Teammate::ACCEPTED)
  schedule_event.teammates.create(user: organizer, email: organizer.email, role: "organizer", state: Teammate::ACCEPTED)

  # Session Formats
  schedule_conf_formats = {}
  schedule_conf_formats[0] = schedule_event.public_session_formats.create(name: "Lightning Talk", duration: 5, description: "Warp speed! Leave your audience breathless and thirsty for more.")
  schedule_conf_formats[1] = schedule_event.public_session_formats.create(name: "Short Talk", duration: 30, description: "Kinda short! Talk fast. Talk hard.")
  schedule_conf_formats[2] = schedule_event.public_session_formats.create(name: "Long Talk", duration: 60, description: "Longer talk allows a speaker put more space in between words, hand motions.")
  schedule_conf_formats[3] = schedule_event.session_formats.create(name: "Beenote", public: false, duration: 90, description: "Involves live bees.")

  # Tracks
  schedule_conf_tracks = {}
  schedule_conf_tracks[0] = schedule_event.tracks.create(name: "Best Track", description: "Better than all the other tracks.", guidelines: "Watch yourself. Watch everybody else. All of us are winners in the best track.")
  schedule_conf_tracks[1] = schedule_event.tracks.create(name: "OK Track", description: "This track is okay.", guidelines: "Mediocrity breeds mediocrity. Let's talk about how to transcend the status quo.")
  schedule_conf_tracks[2] = schedule_event.tracks.create(name: "Boring Track", description: "Great if you want a nap!", guidelines: "Sleep deprivation is linked to many health problem. Get healthy here so you can be 100% for the Best Track.")

  # Rooms
  conference_address = Faker::Address.street_address
  4.times do |i|
    schedule_event.rooms.create(name: "#{Faker::Name.last_name} Room", room_number: Faker::Number.number(3), level: 1, address: conference_address, capacity: 150)
  end

  # Program Sessions
  120.times do |i|
    speaker_user = User.create(name: Faker::Name.name, email: Faker::Internet.email, password: pwd, password_confirmation: pwd, confirmed_at: Time.now)

    accepted_proposal = schedule_event.proposals.create({
      event: seed_event,
      uuid: "xoxoxo",
      state: "accepted",
      title: Faker::Superhero.name,
      abstract: Faker::Hipster.sentence,
      details: Faker::Hacker.say_something_smart,
      pitch: Faker::Superhero.power,
      session_format: schedule_conf_formats[(i % 4)],
      track: schedule_conf_tracks[(i % 3)],
      confirmed_at: Time.current
    })

    program_session = schedule_event.program_sessions.create({
      proposal: accepted_proposal,
      state: ProgramSession::LIVE,
      title: accepted_proposal.title,
      abstract: accepted_proposal.abstract,
      track: accepted_proposal.track,
      session_format: accepted_proposal.session_format
    })

    speaker = accepted_proposal.speakers.create({
      speaker_name: speaker_user.name,
      speaker_email: speaker_user.email,
      bio: "I #{Faker::Company.bs}.",
      user: speaker_user,
      event: schedule_event,
      program_session: program_session
    })
  end

  #Create Time Slots for day 1
  schedule_event.rooms.all.each do |room|
    # create slots for lighting sessions
    beginning_of_block = Time.new(2018, 02, 24, 9, 0, 0, "+09:00")
    session_duration = 5
    5.times do |i|
      start_time = (beginning_of_block + (i * session_duration).minutes).strftime('%H:%M')
      end_time = (beginning_of_block + ((i + 1) * session_duration).minutes).strftime('%H:%M')
      empty_slot = schedule_event.time_slots.build({
        room: room,
        conference_day: 1,
        start_time: start_time,
        end_time: end_time,
        title: "",
        description: "",
        presenter: "",
      })
      empty_slot.save(validate: false)
    end

    #create slots for short_talks

    beginning_of_block = Time.new(2018, 02, 24, 10, 0, 0, "+09:00")
    session_duration = 30
    5.times do |i|
      start_time = (beginning_of_block + (i * session_duration).minutes).strftime('%H:%M')
      end_time = (beginning_of_block + ((i + 1) * session_duration).minutes).strftime('%H:%M')
      empty_slot = schedule_event.time_slots.build({
        room: room,
        conference_day: 1,
        start_time: start_time,
        end_time: end_time,
        title: "",
        description: "",
        presenter: "",
      })
      empty_slot.save(validate: false)
    end

    #create slots for long_talks

    beginning_of_block = Time.new(2018, 02, 24, 14, 0, 0, "+09:00")
    session_duration = 60
    3.times do |i|
      start_time = (beginning_of_block + (i * session_duration).minutes).strftime('%H:%M')
      end_time = (beginning_of_block + ((i + 1) * session_duration).minutes).strftime('%H:%M')
      empty_slot = schedule_event.time_slots.build({
        room: room,
        conference_day: 1,
        start_time: start_time,
        end_time: end_time,
        title: "",
        description: "",
        presenter: "",
      })
      empty_slot.save(validate: false)
    end

    # create slot for a beenote

    empty_slot = schedule_event.time_slots.build({
      room: room,
      conference_day: 1,
      start_time: "18:00",
      end_time: "19:30",
      title: "",
      description: "",
      presenter: "",
    })
    empty_slot.save(validate: false)
  end
end

run
