require 'rails_helper'

feature "A user sees correct information for the current event and their role" do
  let!(:normal_user) { create(:user) }
  let!(:reviewer_user) { create(:user) }
  let!(:organizer_user) { create(:user) }
  let!(:admin_user) { create(:user, admin: true) }

  scenario "When there are multiple live events the root is /events" do
    create(:event, state: "open")
    create(:event, state: "open")

    visit root_path
    expect(current_path).to eq(events_path)
  end

  scenario "User flow for a speaker when there is one live event" do
    event_1 = create(:event, state: "open")
    event_2 = create(:event, state: "closed")

    signin(normal_user.email, normal_user.password)

    within ".navbar" do
      expect(page).to have_link(event_1.name)
      expect(page).to have_link("", href: "/notifications")
      expect(page).to have_link(normal_user.name)
    end

    expect(current_path).to eq(event_path(event_1.slug))

    expect(page).to have_link(event_1.name)
    expect(page).to_not have_link(event_2.name)

    find("h1").click
    expect(current_path).to eq(event_path(event_1.slug))
    within ".navbar" do
      expect(page).to have_content(event_1.name)
      expect(page).to have_link("", href: "/notifications")
      expect(page).to have_content(normal_user.name)
      expect(page).to_not have_content("My Proposals")
    end

    proposal = create(:proposal, :with_speaker)
    normal_user.proposals << proposal
    visit root_path
    expect(page).to have_content("My Proposals")
  end

  scenario "User flow for a speaker when there is no live event" do
    event_1 = create(:event, state: "closed")
    event_2 = create(:event, state: "closed")
    proposal = create(:proposal, :with_speaker)

    signin(normal_user.email, normal_user.password)

    within ".navbar" do
      expect(page).to have_content("CFPApp")
      expect(page).to have_link("", href: "/notifications")
      expect(page).to have_link(normal_user.name)
    end

    expect(current_path).to eq(events_path)

    expect(page).to have_link(event_1.name)
    expect(page).to have_link(event_2.name)

    click_on event_2.name
    expect(current_path).to eq(event_path(event_2.slug))

    within ".navbar" do
      expect(page).to have_content(event_2.name)
      expect(page).to have_link("", href: "/notifications")
      expect(page).to have_content(normal_user.name)
      expect(page).to_not have_content("My Proposals")
    end

    normal_user.proposals << proposal
    visit root_path
  end

  scenario "User flow and navbar layout for a reviewer" do
    event_1 = create(:event, state: "open")
    event_2 = create(:event, state: "open")
    proposal = create(:proposal, :with_reviewer_public_comment)
    create(:event_teammate, :reviewer, user: reviewer_user, event: event_1)
    create(:event_teammate, :reviewer, user: reviewer_user, event: event_2)

    signin(reviewer_user.email, reviewer_user.password)

    click_on(event_1.name)

    within ".navbar" do
      expect(page).to have_content(event_1.name)
      expect(page).to have_link(reviewer_user.name)
      expect(page).to_not have_link("My Proposals")
      expect(page).to have_link("", href: "/notifications")
      expect(page).to have_content("Review Proposals")
    end


    reviewer_user.proposals << proposal
    visit event_path(event_2.slug)

    within ".navbar" do
      expect(page).to have_content("My Proposals")
      expect(page).to have_content("Review Proposals")
    end

    visit event_path(event_1.slug)

    within ".navbar" do
      expect(page).to have_content("My Proposals")
      expect(page).to have_content("Review Proposals")
    end

    click_on("Review Proposals")
    expect(page).to have_content(event_1.name)
    expect(current_path).to eq(reviewer_event_proposals_path(event_1.id))
  end

  scenario "User flow for an organizer" do
    event_1 = create(:event, state: "open")
    event_2 = create(:event, state: "closed")
    proposal = create(:proposal, :with_organizer_public_comment)
    create(:event_teammate, :organizer, user: organizer_user, event: event_1)
    create(:event_teammate, :organizer, user: organizer_user, event: event_2)

    signin(organizer_user.email, organizer_user.password)

    find("h1").click

    within ".navbar" do
      expect(page).to have_content(event_1.name)
      expect(page).to have_link("", href: "/notifications")
      expect(page).to have_link(reviewer_user.name)
      expect(page).to have_content("Review Proposals")
      expect(page).to have_content("Organize Proposals")
      expect(page).to have_content("Program")
      expect(page).to have_content("Schedule")
      expect(page).to_not have_link("My Proposals")
    end

    organizer_user.proposals << proposal
    visit event_path(event_2.slug)

    within ".navbar" do
      expect(page).to have_link("", href: "/notifications")
      expect(page).to have_content("My Proposals")
      expect(page).to have_content("Review Proposals")
      expect(page).to have_content("Organize Proposals")
      expect(page).to have_content("Program")
      expect(page).to have_content("Schedule")
    end

    visit event_path(event_1.slug)

    within ".navbar" do
      expect(page).to have_link("", href: "/notifications")
      expect(page).to have_content("My Proposals")
      expect(page).to have_content("Review Proposals")
      expect(page).to have_content("Organize Proposals")
      expect(page).to have_content("Program")
      expect(page).to have_content("Schedule")
    end

    click_on("Organize Proposals")
    expect(page).to have_content(event_1.name)
    expect(current_path).to eq(organizer_event_proposals_path(event_1.id))
  end

  scenario "User flow for an admin" do
    event_1 = create(:event, state: "open")
    event_2 = create(:event, state: "closed")
    proposal = create(:proposal, :with_organizer_public_comment)
    create(:event_teammate, :organizer, user: admin_user, event: event_1)
    create(:event_teammate, :organizer, user: admin_user, event: event_2)

    signin(admin_user.email, admin_user.password)

    find("h1").click

    within ".navbar" do
      expect(page).to have_content(event_1.name)
      expect(page).to have_link("", href: "/notifications")
      expect(page).to have_link(reviewer_user.name)
      expect(page).to_not have_link("My Proposals")
      expect(page).to have_content("Program")
      expect(page).to have_content("Schedule")
      expect(page).to have_content("Review Proposals")
      expect(page).to have_content("Organize Proposals")
    end

    admin_user.proposals << proposal
    visit event_path(event_2.slug)

    within ".navbar" do
      expect(page).to have_link("", href: "/notifications")
      expect(page).to have_content("My Proposals")
      expect(page).to have_content("Review Proposals")
      expect(page).to have_content("Organize Proposals")
      expect(page).to have_content("Program")
      expect(page).to have_content("Schedule")
    end

    visit event_path(event_1.slug)

    within ".navbar" do
      expect(page).to have_link("", href: "/notifications")
      expect(page).to have_content("My Proposals")
      expect(page).to have_content("Review Proposals")
      expect(page).to have_content("Organize Proposals")
      expect(page).to have_content("Program")
      expect(page).to have_content("Schedule")
    end


    click_on("Organize Proposals")
    expect(page).to have_content(event_1.name)
    expect(current_path).to eq(organizer_event_proposals_path(event_1.id))

    within ".navbar" do
      click_on("Program")
    end
    expect(page).to have_content(event_1.name)
    expect(current_path).to eq(organizer_event_program_path(event_1.id))

    visit "/events"
    click_on(event_2.name)

    within ".navbar" do
      click_on("Schedule")
    end
    expect(page).to have_content(event_2.name)
    expect(current_path).to eq(organizer_event_sessions_path(event_2.id))

    click_link admin_user.name
    click_link "Users"
    expect(current_path).to eq(admin_users_path)

    visit root_path
    click_link admin_user.name
    click_link "Manage Events"
    expect(current_path).to eq(admin_events_path)

    within ".table" do
      expect(page).to have_content(event_1.name)
      expect(page).to have_content("open")

      expect(page).to have_content(event_2.name)
      expect(page).to have_content("closed")

      first(:link, "Archive").click
    end

    expect(page).to have_content("#{event_1.name} is now archived.")
    expect(page).to have_link("Unarchive")

    within ".table" do
      click_on event_1.name
    end

    within ".navbar" do
      expect(page).to_not have_content("Review Proposals")
      expect(page).to_not have_content("Organize Proposals")
      expect(page).to_not have_content("Program")
      expect(page).to_not have_content("Schedule")
    end
  end
end
