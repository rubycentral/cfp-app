require 'rails_helper'

RSpec.describe ConfirmationsMailer, type: :mailer do
  describe '#confirmation_instructions' do
    it 'mails the pending address when present, with a working confirm link' do
      user = create(:user)
      user.update_columns(unconfirmed_email: 'pending@addr.com')

      mail = ConfirmationsMailer.confirmation_instructions(user)

      expect(mail.to).to eq(['pending@addr.com'])
      expect(mail.subject).to eq('Confirmation instructions')
      token = mail.body.encoded.match(%r{confirmations/([^"&]+)})[1]
      expect(User.find_by_email_confirmation_token(CGI.unescape(token))).to eq(user)
    end

    it 'mails the primary address otherwise' do
      user = create(:user)

      expect(ConfirmationsMailer.confirmation_instructions(user).to).to eq([user.email])
    end
  end
end
