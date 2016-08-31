module ApplicationHelper

  def title
    if @title.blank?
      "CFPApp"
    else
      @title
    end
  end

  def demographic_label(demographic)
    case demographic
      when :gender then
        "Gender Identity"
      else
        demographic.to_s.titleize
    end
  end

  class MarkdownRenderer < Redcarpet::Render::HTML
    def block_code(code, language)
      language ||= :ruby
      CodeRay.highlight(code, language)
    end
  end

  def markdown(text)
    return unless text

    rndr = MarkdownRenderer.new(:filter_html => true, :hard_wrap => true)
    options = {
      :fenced_code_blocks => true,
      :no_intra_emphasis => true,
      :autolink => true,
      :strikethrough => true,
      :lax_html_blocks => true,
      :superscript => true
    }
    markdown_to_html = Redcarpet::Markdown.new(rndr, options)
    markdown_to_html.render(text).html_safe
  end

  def smart_return_button
    if session.has_key?(:prev_page)
      name = session[:prev_page]["name"]
      path = session[:prev_page]["path"]
    else
      name = 'Proposals'
      path = event_staff_program_proposals_path
    end

    link_to("« Return to #{name}", path, class: "btn btn-primary btn-sm", id: "back")
  end

  def show_flash
    flash.map do |key, value|
      key += " alert-info" if key == "notice"
      key = "danger" if key == "alert"
      content_tag(:div, class: "container alert alert-dismissable alert-#{key}") do
        content_tag(:button, content_tag(:span, '', class: 'glyphicon glyphicon-remove'),
                    class: 'close', data: {dismiss: 'alert'}) +
          simple_format(value)
      end
    end.join.html_safe
  end

  def copy_email_btn
    link_to "<i class='fa fa-files-o'></i> Copy Speaker Emails".html_safe, '#',
            data: {url: event_staff_speaker_emails_path(@event)},
            class: "btn btn-primary btn-sm",
            id: 'copy-filtered-speaker-emails'
  end

  def modal(identifier, title = '')
    body = capture { yield }
    render 'shared/modal', identifier: identifier, body: body, title: title
  end

  def body_id
    "#{controller_path.tr('/','_')}_#{action_name}"
  end

  def speaker_nav?
    current_user.proposals.present? || current_user.pending_invitations.present?
  end

  def review_nav?
    current_user.reviewer_for_event?(current_event)
  end

  def program_nav?
    # add program team to the check
    current_user.organizer_for_event?(current_event)
  end

  def schedule_nav?
    current_user.organizer_for_event?(current_event)
  end

  def staff_nav?
    event_staff?(current_event)
  end

  def admin_nav?
    current_user.admin?
  end
end
