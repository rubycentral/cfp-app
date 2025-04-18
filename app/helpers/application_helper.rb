module ApplicationHelper

  def title
    if @title.blank?
      "CFPApp"
    else
      @title
    end
  end

  def boolean_to_words(value)
    value ? "Yes" : "No"
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
    safe_join(
      flash.map do |key, value|
        key += " alert-info" if key == "notice" || key == 'confirm'
        key = "danger" if key == "alert"
        content_tag(:div, class: "container alert alert-dismissable alert-#{key}") do
          content_tag(:button, content_tag(:span, '', class: 'glyphicon glyphicon-remove'),
                      class: 'close', data: {dismiss: 'alert'}) +
            simple_format(value)
        end
      end
    )
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
    current_user.proposals.any? || current_user.pending_invitations.any?
  end

  def review_nav?(roles)
    (roles & Teammate::STAFF_ROLES).any?
  end

  def program_nav?(roles)
    ((roles & Teammate::PROGRAM_TEAM_ROLES).any? && current_event.closed?) || roles.include?('organizer')
  end

  def schedule_nav?(roles)
    roles.include?('organizer')
  end

  def staff_nav?(roles)
    roles.any?
  end

  def website_nav?
    policy(Website).show?
  end

  def admin_nav?
    current_user.admin?
  end

  def new_or_edit_website_path
    if current_website
      edit_event_staff_website_path(current_event)
    else
      new_event_staff_website_path(current_event)
    end
  end
end
