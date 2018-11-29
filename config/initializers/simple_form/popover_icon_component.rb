module SimpleForm
  module Components
    module PopoverIcons
      def popover_icon(wrapper_options = nil)
        return if popover_content.blank?

        input_html_options[:rel] ||= 'popover'
        input_html_options[:data] ||= {}
        input_html_options[:data][:toggle] ||= 'popover'
        input_html_options[:data][:html] ||= true
        input_html_options[:data][:placement] ||= popover_placement if popover_placement
        input_html_options[:data][:trigger] ||= 'manual'
        input_html_options[:data]['original-title'] ||= popover_title if popover_title
        input_html_options[:data][:content] ||= popover_content
        input_html_options[:data][:animation] ||= false
        input_html_options[:data][:container] ||= popover_container if popover_container
        nil
      end

      def icon
        return if popover_content.blank?
        template.capture do
          template.content_tag(:a, class:'btn btn-icon hint-btn popover-trigger', data: { target: popover_selector }) do
            template.content_tag(:i, '', class: 'fa fa-fw fa-question-circle')
          end
        end.html_safe
      end

      def label_text(wrapper_options = nil)
        label_text = options[:label_text] || SimpleForm.label_text
        label_text.call(html_escape(raw_label_text), required_label_text, options[:label].present?, icon).strip.html_safe
      end

      def popover_selector
        selector = "##{@builder.object_name}_#{@attribute_name}"
        selector.gsub!(/([^a-z0-9#]+)/i, '_')
        # selector += "_#{object.id}" if object.try(:id)
        selector
      end

      def popover_content
        popover = options[:popover_icon]
        if popover.is_a?(String)
          popover
        elsif popover.is_a?(Hash)
          popover[:content]
        else
          nil
        end
      end

      def popover_title
        popover = options[:popover_icon]
        if popover.is_a?(Hash)
          popover[:title]
        end
      end

      def popover_placement
        popover = options[:popover_icon]
        popover.is_a?(Hash) ? popover[:placement] : 'right'
      end

      def popover_container
        popover = options[:popover_icon]
        popover.is_a?(Hash) ? popover[:container] : 'body'
      end
    end
  end
end

SimpleForm::Inputs::Base.send(:include, SimpleForm::Components::PopoverIcons)
