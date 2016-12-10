module FeatureHelper
  def login_user(user)
    allow(User).to receive(:authenticate).and_return('developer', user)
    allow(User).to receive(:find_by).and_return(user)
    User.authenticate(user)
  end
end
