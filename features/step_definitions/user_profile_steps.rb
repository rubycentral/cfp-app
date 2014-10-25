Given(/^I am logged on as a user$/) do
  user = FactoryGirl.create(:person)
  expect(Person.count).to eq 1
  login_user(user)
end

Given(/^I am on the edit profile page$/) do
  Pages.make(Profile).visit
end

Given(/^I set up my demographics information$/) do
  Pages.make(Profile).set_up_demographics_info
end

Given(/^I change my demographics information$/) do
  # Set up the initial demographics info
  user = Person.last
  demographics_info = Pages.make(Profile).default_demographics_info
  user.demographics['genger'] = demographics_info.fetch(:gender)
  user.demographics['ethnicity'] = demographics_info.fetch(:ethnicity)
  user.demographics['country'] = demographics_info.fetch(:country)
  user.save!

  profile_page = Pages.make(Profile)
  profile_page.set_up_demographics_info(profile_page.changed_demographics_info)
end

When(/^I save the profile form$/) do
  Pages.make(Profile).submit_form
end

Then(/^my demographics data is updated$/) do
  user = Person.last
  demographics_info = Pages.make(Profile).default_demographics_info

  assert_user_demographics(user, demographics_info)
end

Then(/^my demographics data is changed$/) do
  user = Person.last
  demographics_info = Pages.make(Profile).changed_demographics_info

  assert_user_demographics(user, demographics_info)
end

def assert_user_demographics(user, demographics_info)
  expect(user.demographics['gender']).to eq(demographics_info.fetch(:gender))
  expect(user.demographics['ethnicity']).to eq(demographics_info.fetch(:ethnicity))
  expect(user.demographics['country']).to eq(demographics_info.fetch(:country))
end
