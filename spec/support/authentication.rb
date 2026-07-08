module AuthenticationSpecHelpers
  def sign_in(user)
    session_record = user.sessions.create!

    case self.class.metadata[:type]
    when :controller
      request.cookie_jar.signed[:session_id] = session_record.id
    when :request
      cookies[:session_id] = signed_session_cookie(session_record)
    end
  end

  def signed_session_cookie(session_record)
    jar = ActionDispatch::Cookies::CookieJar.build(ActionDispatch::TestRequest.create, {})
    jar.signed[:session_id] = session_record.id
    jar[:session_id]
  end
end

module SystemAuthenticationHelpers
  include AuthenticationSpecHelpers

  # Warden-compatible signature; scope is ignored
  def login_as(user, scope: nil)
    session_record = user.sessions.create!
    value = signed_session_cookie(session_record)

    if page.driver.is_a?(Capybara::RackTest::Driver)
      page.driver.browser.set_cookie("session_id=#{CGI.escape(value)}")
    else
      # selenium needs a real page loaded on the app's domain before add_cookie
      visit '/404' unless page.driver.browser.current_url.start_with?('http')
      page.driver.browser.manage.add_cookie(name: 'session_id', value: CGI.escape(value))
    end
  end

  def logout(*)
    if page.driver.is_a?(Capybara::RackTest::Driver)
      page.driver.browser.clear_cookies
    else
      page.driver.browser.manage.delete_cookie('session_id')
    end
  end
end

RSpec.configure do |config|
  config.include AuthenticationSpecHelpers, type: :controller
  config.include AuthenticationSpecHelpers, type: :request
  config.include SystemAuthenticationHelpers, type: :system
end
