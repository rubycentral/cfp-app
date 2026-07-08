class Users::RegistrationsController < Devise::RegistrationsController
  private

  # Devise still owns registration (until PR 2), but sign-in state now lives
  # in the Rails 8 Session cookie, not Warden. Bridge sign-up to the new stack
  # so a freshly registered user is actually signed in.
  #
  # Deliberately NOT using start_authenticated_session/reset_session here: a
  # fresh sign-up has no prior authenticated session to fixate, and the
  # pending-invite session flow through this action is more delicate to
  # rework safely. Left as a known omission for PR 2.
  def sign_up(resource_name, resource)
    start_new_session_for(resource)
  end
end
