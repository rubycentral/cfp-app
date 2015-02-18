module Pages
  class Factory
    class << self

      def make(klass)
        return page_objects[klass] if page_objects.has_key? klass

        page_objects[klass] = klass.new Capybara.current_session

        page_objects[klass]
      end

      private

      def page_objects
        if @page_objects.nil?
          @page_objects = {}
        end

        @page_objects
      end
    end
  end
end
