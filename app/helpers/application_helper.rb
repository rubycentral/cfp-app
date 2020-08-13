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
      key += " alert-info" if key == "notice" || key == 'confirm'
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
            class: "btn btn-primary btn-sm",
            id: 'copy-filtered-speaker-emails'
  end

  def promote_button(program_session)
    if program_session.can_promote?
      link_to 'Promote', promote_event_staff_program_session_path(program_session.event, program_session), method: :patch, data: { confirm: "Are you sure you want to promote #{program_session.title}?" }, class: 'btn btn-warning'
    end
  end

  def finalize_info
    if current_event.proposals.soft_states.any?
      content_tag(:span, "You can use the following bulk actions to finalize the state of all proposals.", class: "text-info")
    else
      content_tag(:span, "There are no proposals awaiting finalization.", class: "text-warning")
    end
  end

  def bang(label)
    content_tag(:span, '',
                class: 'glyphicon glyphicon-exclamation-sign') + ' ' + label
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
    (current_user.program_team_for_event?(current_event) && current_event.closed?) || current_user.organizer_for_event?(current_event)
  end

  def schedule_nav?
    current_user.organizer_for_event?(current_event)
  end

  def staff_nav?
    current_user.staff_for?(current_event)
  end

  def admin_nav?
    current_user.admin?
  end

  def twitter_oauth?
    ENV['TWITTER_KEY'].present?
  end

  def github_oauth?
    ENV['GITHUB_KEY'].present?
  end

  def google_oauth?
    ENV['GOOGLE_OAUTH_CLIENT_ID'].present?
  end  
end
