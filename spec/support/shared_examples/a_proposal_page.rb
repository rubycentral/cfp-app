shared_examples "a proposal page" do |path_method|
  let!(:event) { create(:event, review_tags: [ 'intro', 'advanced' ], valid_proposal_tags: 'intro, advanced') }
  let!(:proposal) { create(:proposal, event: event) }
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

        expect(page).to have_css('.comment', 'A new comment')
      end

      it "can leave an internal comment" do
        form = find('#new_internal_comment')

        form.fill_in 'internal_comment_body', with: 'A new comment'
        form.click_button 'Comment'

        expect(page).to have_css('.internal-comments .comment', 'A new comment')
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

      it "can tag a proposal", js: true
        # this fails due to magic of boostrap .btn-group, .multiselect, etc.,
        # where Capybara cannot find the element:
        # Capybara::ElementNotFound:
        #   Unable to find css "button.multiselect"

        # Google 'capaybara btn-group bootstrap' for more info

        # button_selector = 'button.multiselect'
        # button = find(button_selector)
        # button.click
        #
        # check 'beginner'
        # check 'advanced'
        #
        # # Ideally we could click 'button' again and it would hide the
        # # dropdown list of tags. However, if you try to click the button
        # # directly capybara complains that the dropdown list is overlapping
        # # the element to be clicked. This js snippet manually triggers the
        # # click event on the multiselect button.
        # page.execute_script("$('#{button_selector}').trigger('click');")
        #
        # click_button 'Update'
        #
        # expect(page).to have_css('span.label-success', text: 'INTRO')
        # expect(page).to have_css('span.label-success', text: 'ADVANCED')
      # end
    end
  end
end
