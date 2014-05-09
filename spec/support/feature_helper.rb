module FeatureHelper
  def login_user(user)
    Person.stub(:authenticate).and_return('developer', user)
    Person.stub(:find_by_id).and_return(user)
    Person.authenticate(user)
  end
end
