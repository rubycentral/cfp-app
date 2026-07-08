class Users::RegistrationsController < Devise::RegistrationsController
  private

  # Devise still owns registration (until PR 2), but sign-in state now lives
  # in the Rails 8 Session cookie, not Warden. Bridge sign-up to the new stack
  # so a freshly registered user is actually signed in.
  def sign_up(resource_name, resource)
    start_new_session_for(resource)
  end
end
