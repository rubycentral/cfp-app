module FeatureHelper
  def login_user(user)
    allow(Person).to receive(:authenticate).and_return('developer', user)
    allow(Person).to receive(:find_by).and_return(user)
    Person.authenticate(user)
  end
end
