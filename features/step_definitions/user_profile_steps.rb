Given(/^I am logged on as a user$/) do
  user = FactoryGirl.create(:person)
  expect(Person.count).to eq 1
  login_user(user)
end

Given(/^I am on the edit profile page$/) do
  visit(edit_profile_path)
end

Given(/^I set up my demographics information$/) do
  fill_in 'person[gender]',    with: 'female'
  fill_in 'person[ethnicity]', with: 'Asian'

  select('United States of America', from: 'person[country]')
end

When(/^I save the profile form$/) do
  click_button 'Save'
end

Then(/^my demographics data is updated$/) do
  user = Person.last

  expect(user.demographics['gender']).to eq("female")
  expect(user.demographics['ethnicity']).to eq("Asian")
  expect(user.demographics['country']).to eq("United States of America")
end
