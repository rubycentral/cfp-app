class ApplicationDecorator < Draper::Decorator
  protected

  def twitter_button(text)
    h.link_to "Tweet", "https://twitter.com/share", class: 'twitter-share-button',
      data: { text: text }
  end
end
