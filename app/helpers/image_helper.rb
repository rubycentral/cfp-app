module ImageHelper
  def resize_image_tag(image, width:, height: width)
    return unless image.attached?
    if image.content_type.match('svg')
      image_tag(image, width: width)
    else
      image_tag(image.variant(resize_to_fit: [width, height]))
    end
  end
end
