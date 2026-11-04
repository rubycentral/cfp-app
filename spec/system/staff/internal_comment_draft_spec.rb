require 'rails_helper'

feature "Internal comment draft", type: :system, js: true do
  let(:event) { create(:event, state: 'open') }
  let(:reviewer) { create(:organizer, event: event) }
  let(:proposal) { create(:proposal_with_track, event: event) }
  let(:draft_key) { "internal_comment_draft_#{proposal.id}" }

  before do
    login_as(reviewer)
    # Internal comments are only shown once the reviewer has rated the proposal.
    create(:rating, proposal: proposal, user: reviewer)
    visit event_staff_proposal_path(event, proposal)
  end

  def read_draft(key)
    page.evaluate_script("localStorage.getItem(#{key.to_json})")
  end

  # Wait out the controller's debounce until the draft lands in localStorage.
  def wait_for_draft(key, value)
    start = Time.now
    until read_draft(key) == value
      raise "draft #{key.inspect} was not saved within #{Capybara.default_max_wait_time}s" if Time.now - start > Capybara.default_max_wait_time
      sleep 0.05
    end
  end

  def draft_keys
    page.evaluate_script("Object.keys(localStorage).filter(key => key.includes('comment_draft'))")
  end

  scenario "restores the internal comment draft after a reload" do
    fill_in 'internal_comment_body', with: 'Draft in progress'
    wait_for_draft(draft_key, 'Draft in progress')

    visit event_staff_proposal_path(event, proposal)

    expect(page).to have_field('internal_comment_body', with: 'Draft in progress')
  end

  scenario "clears the draft after a successful submit" do
    fill_in 'internal_comment_body', with: 'A new comment'
    wait_for_draft(draft_key, 'A new comment')

    within '#new_internal_comment' do
      click_button 'Comment'
    end
    expect(page).to have_css('.internal-comments .comment', text: 'A new comment')

    expect(read_draft(draft_key)).to be_nil
  end

  scenario "does not persist a draft for public comments" do
    fill_in 'public_comment_body', with: 'Public draft'
    # Positive control: prove the draft machinery has run before asserting
    # that the public textarea produced no draft.
    fill_in 'internal_comment_body', with: 'control'
    wait_for_draft(draft_key, 'control')

    expect(draft_keys).to eq([draft_key])
  end
end
