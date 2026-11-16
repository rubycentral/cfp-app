module ImageHelper
  def resize_image_tag(image, width:, height: width)
    width ||= 100
    return unless image.attached?
    if image.content_type.match('svg')
      image_tag(image, width: width)
    else
      image_tag(image.variant(resize_to_fit: [width, height]))
    end
  end

  def image_input(form, field, width: 100)
    image = form.object.send(field)
    title = field.to_s.titleize
    attached = image.attached?
    input = ""
    if attached
      input << form.label(field, "Current #{title}", class: "control-label")
      input << content_tag(:div, resize_image_tag(image, width: width))
    end
    input << form.input(field, label: attached ? "Replace #{title}" : "#{title}")
    input.html_safe
  end
end
