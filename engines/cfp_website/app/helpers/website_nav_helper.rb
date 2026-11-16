module WebsiteNavHelper
  def website_nav?
    policy(Website).show?
  end

  def new_or_edit_website_path
    if current_website
      edit_event_staff_website_path(current_event)
    else
      new_event_staff_website_path(current_event)
    end
  end

  def display_website_subnav?
    @display_website_subnav
  end
end
