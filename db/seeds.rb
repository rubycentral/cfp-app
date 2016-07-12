pwd = "userpass"
start_date = 8.months.from_now

## Users
admin = User.create(name: "Admin", email: "an@admin.com", admin: true, password: pwd, password_confirmation: pwd, confirmed_at: Time.now)
organizer = User.create(name: "Event MC", email: "mc@seed.event", password: pwd, password_confirmation: pwd, confirmed_at: Time.now)
track_director = User.create(name: "Track Director", email: "track@seed.event", password: pwd, password_confirmation: pwd, confirmed_at: Time.now)
reviewer = User.create(name: "Reviewer", email: "review@seed.event", password: pwd, password_confirmation: pwd, confirmed_at: Time.now)
speaker = User.create(name: "Speaker", email: "speak@seed.event", password: pwd, password_confirmation: pwd, confirmed_at: Time.now)
speaker_reviewer = User.create(name: "Speak and Review", email: "both@seed.event", password: pwd, password_confirmation: pwd, confirmed_at: Time.now)

# Core Event Info
guidelines = %Q[
# SeedConf wants you!

The first annual conference about seed data is happening
in sunny Phoenix, Arizona on December 1st, 2016!

If your talk is about seed data in Rails apps, we want to hear about it!
]

seed_event = Event.create(name: "SeedConf", slug: "seedconf", contact_email: "info@seed.event",
  closes_at: 6.months.from_now, state: "open",
  start_date: start_date, end_date: start_date + 1,
  guidelines: guidelines, proposal_tags: %w(beginner intermediate advanced))


# session formats
short_session_format = seed_event.public_session_formats.create(name: 'Short Talk', duration: 40, description: 'Kinda short! Talk fast. Talk hard.')
long_session_format = seed_event.public_session_formats.create(name: 'Long Talk', duration: 120, description: 'Longer talk allows a speaker put more space in between words, hand motions.')
internal_session_format = seed_event.session_formats.create(name: 'Beenote', public: false, duration: 180, description: 'Involves live bees.')

# tracks
best_track = seed_event.tracks.create(name: 'Best Track', description: 'Better than all the other tracks.', guidelines: 'Watch yourself. Watch everybody else. All of us are winners in the best track.')

# rooms


# Event Team
seed_event.event_teammates.create(user: organizer, role: "organizer", notifications: false)
seed_event.event_teammates.create(user: track_director, role: "organizer") # < update to program team
seed_event.event_teammates.create(user: reviewer, role: "reviewer")
seed_event.event_teammates.create(user: speaker_reviewer, role: "reviewer")


# Proposals
