module Features
  module DomainHelpers
    def with_domain(host)
      original_host = Capybara.app_host
      Capybara.app_host = "http://#{host}"
      yield
    ensure
      Capybara.app_host = original_host
    end
  end
end

