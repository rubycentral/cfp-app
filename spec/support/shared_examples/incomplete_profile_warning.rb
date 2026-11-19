# Pages that nag about an incomplete profile. The host defines `user` (signed in),
# `visit_page`, and the `lead_in` / `trailing` text around the list of problems.
RSpec.shared_examples_for 'an incomplete profile warning' do
  def expect_warning(*problems)
    visit_page
    expect(page).to have_text("#{lead_in} #{problems.to_sentence}#{trailing}")
  end

  it 'lists a missing name' do
    user.update(name: nil)
    expect_warning("Name can't be blank")
  end

  it 'lists an email change awaiting confirmation' do
    user.update(unconfirmed_email: 'changed@email.com')
    expect_warning('Email changed@email.com needs confirmation')
  end

  it 'lists a missing name alongside an unconfirmed email' do
    user.update(name: nil, unconfirmed_email: 'changed@email.com')
    expect_warning("Name can't be blank", 'Email changed@email.com needs confirmation')
  end

  context 'for an account without an email' do
    let(:user) { create(:user, email: '', provider: 'twitter') }

    it 'lists the missing email' do
      expect_warning("Email can't be blank")
    end

    context 'and without a name either' do
      let(:user) { create(:user, email: '', name: nil, provider: 'twitter') }

      it 'lists both' do
        expect_warning("Name can't be blank", "Email can't be blank")
      end
    end

    it 'reports only the pending confirmation once a new email awaits it' do
      user.update(unconfirmed_email: 'changed@email.com')
      expect_warning('Email changed@email.com needs confirmation')
    end
  end
end
