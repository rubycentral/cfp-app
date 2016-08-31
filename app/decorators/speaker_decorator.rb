class SpeakerDecorator < ApplicationDecorator
  delegate_all
  decorates_association :proposals
  decorates_association :program_sessions

  def gravatar
    image_url =
      "https://www.gravatar.com/avatar/#{object.gravatar_hash}?s=50"

    h.image_tag(image_url, class: 'pull-left speaker-image')
  end

  def name_and_email
    "#{object.name} (#{object.email})"
  end

  def bio
    object.bio.present? ? object.bio : object.user.try(:bio)
  end

  def delete_button
    h.button_to h.event_staff_program_speaker_path,
                form_class: "inline-block form-inline",
                method: :delete,
                data: {
                  confirm:
                    'This will delete this speaker. Are you sure you want to do this? It can not be undone.'
                },
                class: 'btn btn-danger navbar-btn',
                id: 'delete' do
      bang('Delete Speaker')
    end
  end
end
