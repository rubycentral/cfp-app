require 'spec_helper'

def select_demographics(args)
  select(args[:gender], from: 'person[gender]')
  select(args[:ethnicity], from: 'person[ethnicity]')
  select(args[:country], from: 'person[country]')
end

feature 'User Profile' do
  let(:user) { create(:person) }

  before { login_user(user) }


  scenario "A user can save demographics info" do
    visit(edit_profile_path)
    select_demographics(gender: 'female', ethnicity: 'Asian', country: 'Albania')
    click_button 'Save'

    expect(user.demographics['gender']).to eq("female")
    expect(user.demographics['ethnicity']).to eq("Asian")
    expect(user.demographics['country']).to eq("Albania")
  end

  scenario "A user can change their demographic info" do
    visit(edit_profile_path)
    select_demographics(gender: 'female', ethnicity: 'Asian', country: 'Albania')
    click_button 'Save'

    visit(edit_profile_path)
    select_demographics(gender: 'not listed here', ethnicity: 'Caucasian', country: 'Algeria')
    click_button 'Save'

    expect(user.demographics['gender']).to eq('not listed here')
    expect(user.demographics['ethnicity']).to eq('Caucasian')
    expect(user.demographics['country']).to eq('Algeria')
  end

  scenario "A user can save their bio" do
    visit(edit_profile_path)
    fill_in('Bio', with: 'I am awesome')
    click_button 'Save'

    expect(user.bio).to eq('I am awesome')
  end

  scenario "A user can edit their bio" do
    visit(edit_profile_path)
    fill_in('Bio', with: 'I am awesome')
    click_button 'Save'

    visit(edit_profile_path)
    fill_in('Bio', with: 'I am even more awesome')
    click_button 'Save'

    expect(user.bio).to eq('I am even more awesome')
  end
end
