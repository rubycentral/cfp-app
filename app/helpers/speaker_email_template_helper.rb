module SpeakerEmailTemplateHelper
  def display_template_type(type)
    if type == "reject"
      "Not Accepted"
    else
      type
    end
  end
end
