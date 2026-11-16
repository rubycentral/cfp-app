module CfpWebsite
  module TimeSlotDecoratorExtension
    def sponsored?
      object.sponsor.present?
    end

    def display_sponsor_star
      h.content_tag(:i, '', class: 'bi bi-star-fill') if sponsored?
    end
  end
end
