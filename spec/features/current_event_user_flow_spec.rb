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
    expect(current_path).to eq(event_path(event_1.slug))

    within ".navbar" do
      expect(page).to have_link(event_1.name)
      expect(page).to_not have_link("My Proposals")
      expect(page).to have_link("", href: "/notifications")
      expect(page).to have_link(normal_user.name)
    end

    within ".page-header" do
      expect(page).to have_content("#{event_1.name} CFP")
      expect(page).to_not have_content("#{event_2.name} CFP")
    end

    speaker = create(:speaker, event: event_1, user: normal_user)
    proposal = create(:proposal, event: event_1)
    proposal.speakers << speaker
    visit root_path

    within ".navbar" do
      expect(page).to have_link("My Proposals")
    end

    [proposals_path, notifications_path, profile_path].each do |path|
      visit path
      within ".navbar" do
        expect(page).to have_link(event_1.name)
      end
    end
  end

  scenario "User flow for a speaker when there are two live events" do
    event_1 = create(:event, state: "open")
    event_2 = create(:event, state: "open")

    signin(normal_user.email, normal_user.password)
    expect(current_path).to eq(events_path)

    within ".navbar" do
      expect(page).to have_link("CFP App")
      expect(page).to_not have_link("My Proposals")
      expect(page).to have_link("", href: "/notifications")
      expect(page).to have_link(normal_user.name)
    end

    expect(page).to have_link(event_1.name)
    expect(page).to have_link(event_2.name)

    click_on(event_1.name)

    within ".navbar" do
      expect(page).to have_link(event_1.name)
      expect(page).to_not have_link(event_2.name)
      expect(page).to_not have_link("CFPApp")
    end

    visit root_path
    visit proposals_path

    within ".navbar" do
      expect(page).to have_link(event_1.name)
    end

    visit root_path
    click_on(event_2.name)

    within ".navbar" do
      expect(page).to have_link(event_2.name)
    end

    visit notifications_path

    within ".navbar" do
      expect(page).to have_link(event_2.name)
    end

    speaker = create(:speaker, event: event_2, user: normal_user)
    proposal = create(:proposal, event: event_2)
    proposal.speakers << speaker

    visit proposals_path

    within ".navbar" do
      expect(page).to have_link(event_2.name)
    end
  end

  scenario "User flow for a speaker when there is no live event" do
    event_1 = create(:event, state: "closed")
    event_2 = create(:event, state: "closed")

    signin(normal_user.email, normal_user.password)

    within ".navbar" do
      expect(page).to have_content("CFP App")
      expect(page).to have_link("", href: "/notifications")
      expect(page).to have_link(normal_user.name)
    end

    expect(current_path).to eq(events_path)

    expect(page).to have_link(event_1.name)
    expect(page).to have_link(event_2.name)

    click_on event_2.name
    expect(current_path).to eq(event_path(event_2))

    within ".navbar" do
      expect(page).to have_content(event_2.name)
      expect(page).to have_link("", href: "/notifications")
      expect(page).to have_content(normal_user.name)
    end

    visit root_path
    click_on event_1.name
    expect(current_path).to eq(event_path(event_1.slug))

    within ".navbar" do
      expect(page).to have_content(event_1.name)
      expect(page).to have_link("", href: "/notifications")
      expect(page).to have_content(normal_user.name)
    end

  end

  scenario "Reviewer flow and navbar layout" do
    event_1 = create(:event, state: "open")
    event_2 = create(:event, state: "open")
    create(:teammate, :reviewer, user: reviewer_user, event: event_1)

    signin(reviewer_user.email, reviewer_user.password)

    click_on event_1.name

    within ".navbar" do
      expect(page).to have_link(event_1.name)
      expect(page).to have_link(reviewer_user.name)
      expect(page).to_not have_link("My Proposals")
      expect(page).to have_link("", href: "/notifications")
      expect(page).to have_content("Review")
    end

    click_on "Review"

    within ".navbar" do
      expect(page).to have_link(event_1.name)
    end

    click_on "Dashboard"

    within ".subnavbar" do
      expect(page).to have_content("Dashboard")
      expect(page).to have_content("Info")
      expect(page).to have_content("Team")
      expect(page).to have_content("Config")
      expect(page).to have_content("Guidelines")
      expect(page).to have_content("Speaker Emails")
    end

    visit root_path

    visit event_path(event_2.slug)

    within ".navbar" do
      expect(page).to have_link(event_2.name)
      expect(page).to have_link(reviewer_user.name)
      expect(page).to_not have_link("My Proposals")
      expect(page).to have_link("", href: "/notifications")
      expect(page).to_not have_content("Review")
    end
  end

  scenario "User flow for an organizer" do
    event_1 = create(:event, state: "open")
    event_2 = create(:event, state: "open")
    proposal = create(:proposal, :with_organizer_public_comment, event: event_2)
    create(:teammate, :organizer, user: organizer_user, event: event_2)

    signin(organizer_user.email, organizer_user.password)

    visit event_path(event_2.slug)

    within ".navbar" do
      expect(page).to have_content(event_2.name)
      expect(page).to_not have_link("My Proposals")
      expect(page).to have_content("Review")
      expect(page).to have_content("Program")
      expect(page).to have_content("Schedule")
      expect(page).to have_content("Dashboard")
      expect(page).to have_link("", href: "/notifications")
      expect(page).to have_link(organizer_user.name)
    end

    click_on "Dashboard"

    within ".navbar" do
      expect(page).to have_content(event_2.name)
    end

    within ".subnavbar" do
      expect(page).to have_content("Dashboard")
      expect(page).to have_content("Info")
      expect(page).to have_content("Team")
      expect(page).to have_content("Config")
      expect(page).to have_content("Guidelines")
      expect(page).to have_content("Speaker Emails")
    end

    click_on "Speaker Emails"
    expect(page).to have_content "Speaker Email Notification Templates"

    speaker = create(:speaker, event: event_2, user: organizer_user)
    proposal.speakers << speaker
    visit event_path(event_1.slug)

    within ".navbar" do
      expect(page).to have_content(event_1.name)
      expect(page).to have_content("My Proposals")
      expect(page).to have_link("", href: "/notifications")
      expect(page).to_not have_content("Review")
      expect(page).to_not have_content("Program")
      expect(page).to_not have_content("Schedule")
      expect(page).to_not have_content("Dashboard")
    end
  end

  scenario "User flow for an admin" do
    event_1 = create(:event, state: "open")
    event_2 = create(:event, state: "closed")
    create(:teammate, :organizer, user: admin_user, event: event_1)
    create(:teammate, :organizer,  event: event_2)

    signin(admin_user.email, admin_user.password)

    visit event_path(event_1.slug)

    within ".navbar" do
      expect(page).to have_content(event_1.name)
      expect(page).to have_content("Users")
      expect(page).to have_content("Admin")
      expect(page).to have_link("", href: "/notifications")
      expect(page).to have_link(admin_user.name)
      expect(page).to_not have_link("My Proposals")
      expect(page).to have_content("Program")
      expect(page).to have_content("Schedule")
      expect(page).to have_content("Review")
    end

    click_on "Admin"
    click_on "Events"

    within ".navbar" do
      expect(page).to have_content(event_1.name)
    end

    within "table" do
      expect(page).to have_link(event_1.name)
      expect(page).to have_link(event_2.name)
    end
  end
end
