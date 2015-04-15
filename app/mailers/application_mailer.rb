class ApplicationMailer < ActionMailer::Base
  helper MailerHelper

  def mail_markdown(options)
    mail options do |format|
      markdown_string = render_to_string(action_name, formats: :md)
      format.text { render text: markdown_string}
      format.html { render text: Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(markdown_string)}
    end
  end
end