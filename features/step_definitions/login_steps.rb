Given(/^I am a user$/) do
  @user = FactoryGirl.create(:person)
  login_user @user
end

When(/^I log on$/) do
  login_user @user
end

Then(/^I should be logged on$/) do
  visit(edit_profile_path)
  expect(current_url).to include(edit_profile_path)
end

def login_user(user)
  allow(Person).to receive(:authenticate).and_return('developer', user)
  allow(Person).to receive(:find_by_id).and_return(user)
  Person.authenticate(user)
end
