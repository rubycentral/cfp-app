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

  def link_to_github
    if (github = person.services.find_by(provider: 'github'))
      gh_login = Rails.cache.fetch "gh_#{github.uid}" do
        JSON.parse(Net::HTTP.get(URI("https://api.github.com/user/#{github.uid}")))['login']
      end
      h.link_to "@#{gh_login}", "https://github.com/#{gh_login}", target: '_blank'
    else
      'none'
    end
  end

  def link_to_twitter
    if (twitter = person.services.find_by(provider: 'twitter'))
      tw_screen_name = Rails.cache.fetch "tw_#{twitter.uid}" do
        Twitter::REST::Client.new(consumer_key: ENV['TWITTER_KEY'], consumer_secret: ENV['TWITTER_SECRET']).user(twitter.uid.to_i).screen_name
      end
      h.link_to "@#{tw_screen_name}", "https://twitter.com/#{tw_screen_name}", target: '_blank'
    else
      'none'
    end
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
