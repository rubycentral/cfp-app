RSpec.shared_examples_for 'an incomplete profile flash message' do
  it 'includes the missing requirements in a flash message' do
    get action, params: params
    expect(flash[:warning]).to eq msg
  end
end

RSpec.shared_examples_for 'an incomplete profile notifier' do
  let(:unconfirmed_email_msg) { " Email #{user.unconfirmed_email} needs confirmation" }
  let(:blank_name_msg) { " Name can't be blank" }
  let(:blank_email_msg) { " Email can't be blank" }
  let(:blank_name_and_email_msg) { " Name can't be blank and Email can't be blank" }
  let(:unconfirmed_email_and_blank_name_msg) do
    " Name can't be blank and Email #{user.unconfirmed_email} needs confirmation"
  end

  context 'name is missing' do
    let(:msg) { lead_in_msg + blank_name_msg + trailing_msg }

    before { user.update(name: nil) }

    it_behaves_like 'an incomplete profile flash message'
  end

  context 'email is missing' do
    let(:user) { create :user, email: '', provider: 'twitter' }
    let(:msg) { lead_in_msg + blank_email_msg + trailing_msg }

    it_behaves_like 'an incomplete profile flash message'
  end

  context 'name and email are missing' do
    let(:user) { create :user, email: '', name: nil, provider: 'twitter' }
    let(:msg) do
      lead_in_msg + blank_name_and_email_msg + trailing_msg
    end

    it_behaves_like 'an incomplete profile flash message'
  end

  context 'an unconfirmed email is present' do
    let(:msg) { lead_in_msg + unconfirmed_email_msg + trailing_msg }

    before { user.update(unconfirmed_email: 'changed@email.com') }

    it_behaves_like 'an incomplete profile flash message'

    context 'name is missing' do
      let(:msg) do
        lead_in_msg + unconfirmed_email_and_blank_name_msg + trailing_msg
      end

      before { user.update(name: nil) }

      it_behaves_like 'an incomplete profile flash message'
    end

    context 'email is missing' do
      let(:user) do
        create :user, email: '', provider: 'twitter'
      end
      let(:msg) { lead_in_msg + unconfirmed_email_msg + trailing_msg }

      it_behaves_like 'an incomplete profile flash message'
    end
  end
end
