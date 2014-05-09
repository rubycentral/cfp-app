class ApplicationDecorator < Draper::Decorator
  protected

  def bang(label)
    h.content_tag(:span, '',
                  class: 'glyphicon glyphicon-exclamation-sign') + ' ' + label
  end

  def twitter_button(text)
    h.link_to "Tweet", "https://twitter.com/share", class: 'twitter-share-button',
      data: { text: text }
  end
end
