class TeammateDecorator < ApplicationDecorator
  delegate_all

  def notification_preference
    Teammate::NOTIFICATION_PREFERENCES[teammate.notification_preference]
  end
end
