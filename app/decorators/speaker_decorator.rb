class SpeakerDecorator < Draper::Decorator
  delegate_all
  decorates_association :proposals
  decorates_association :program_sessions

  def bio
    object.bio.present? ? object.bio : object.user.try(:bio)
  end
end
