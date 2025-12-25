class TeammateDecorator < Draper::Decorator
  delegate_all

  def notification_preference
    Teammate::NOTIFICATION_PREFERENCE_LABELS[teammate.notification_preference]
  end
end
