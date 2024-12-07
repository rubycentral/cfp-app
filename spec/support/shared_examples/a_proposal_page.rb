shared_examples "a proposal page" do |path_method|
  let!(:event) { create(:event, review_tags: [ 'intro', 'advanced' ], valid_proposal_tags: 'intro, advanced') }
  let!(:proposal) { create(:proposal_with_track, event: event) }
  let!(:reviewer) { create(:organizer, event: event) }

  before { login_as(reviewer) }

  context "a reviewer" do
    context "commenting" do

      before do
        create(:rating, proposal: proposal, user: reviewer)
        visit send(path_method, event, proposal)
      end

      it "can leave a public comment" do
        form = find('#new_public_comment')

        form.fill_in 'public_comment_body', with: 'A new comment'
        form.click_button 'Comment'

        expect(page).to have_css('.comment', text: 'A new comment')
      end

      it "can leave an internal comment" do
        form = find('#new_internal_comment')

        form.fill_in 'internal_comment_body', with: 'A new comment'
        form.click_button 'Comment'

        expect(page).to have_css('.internal-comments .comment', text: 'A new comment')
      end
    end

    context "rating and tagging" do
      before { visit send(path_method, event, proposal) }

      it "can rate a proposal", js: true do
        within("#rating-form") do
          find("input[value='5']", visible: false).set(true)
        end
        expect(page).to have_css('.text-success', text: 'Average rating:')
        expect(page).to have_css('.text-success', text: '5.0')
      end
    end
  end
end
