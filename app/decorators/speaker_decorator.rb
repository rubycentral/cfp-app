class SpeakerDecorator < ApplicationDecorator
  delegate_all
  decorates_association :proposals

  def gravatar
    image_url =
      "https://www.gravatar.com/avatar/#{object.gravatar_hash}?s=50"

    h.image_tag(image_url, class: 'pull-left speaker-image')
  end

  def name_and_email
    "#{object.name} (#{object.email})"
  end

  def bio
    speaker.bio.present? ? speaker.bio : speaker.person.bio
  end

  def delete_button
    h.button_to h.organizer_event_speaker_path,
                method: :delete,
                data: {
                  confirm:
                    'This will delete this speaker. Are you sure you want to do this? ' +
                      'It can not be undone.'
                },
                class: 'btn btn-danger navbar-btn',
                id: 'delete' do
      bang('Delete Speaker')
    end
  end
end
