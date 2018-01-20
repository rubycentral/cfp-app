module ProfilesHelper

  def notification_preferences_tooltip
    <<-HTML
     <p><strong>Notification Preferences</strong></p>
     <p><b>All Via Email</b> - You will receive emails for all public and internal comments. You will also receive in-app notications for all public and internal comments. </p>
     <p><b>Mention Only Via Email</b> - You will only receive emails for every public and internal comment that directly mentions your @shortname. You will also receive in-app notications for all public and internal comments.</p>
     <p><b>In App Only</b> - You will not receive any email notifications and only receive in-app notifications for all public and internal comments.</p>
    HTML
  end

end
