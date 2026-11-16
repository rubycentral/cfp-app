# Website lookup, access check, subnav flag and HTTP caching, included into
# ApplicationController when the engine is loaded. All private, as in core.
module CfpWebsite
  module ControllerExtension
    extend ActiveSupport::Concern

    included do
      helper_method :current_website
    end

    private

    def current_website
      @current_website ||= begin
        if current_event
          current_event.website
        elsif params[:slug]
          Website.joins(:event).find_by(events: { slug: params[:slug] })
        else
          older_domain_website || latest_domain_website
        end
      end&.decorate
    end

    def older_domain_website
      @older_domain_website ||=
        domain_websites.find_by(events: { slug: params[:domain_page_or_slug] })
    end

    def latest_domain_website
      @latest_domain_website ||= domain_websites.first
    end

    def domain_websites
      Website.domain_match(request.domain).joins(:event).order(created_at: :desc)
    end

    def require_website
      redirect_to not_found_path and return unless current_website
    end

    def enable_website_subnav
      @display_website_subnav = true
    end

    def set_cache_headers
      return unless Rails.configuration.action_controller.perform_caching

      server_cache_age =
        current_website.caching_off? ? 0 : ENV.fetch('CACHE_CONTROL_S_MAXAGE', 1.week)

      expires_in(
        ENV.fetch('CACHE_CONTROL_MAX_AGE', 0).to_i,
        public: !current_website.caching_off?,
        's-maxage': server_cache_age.to_i
      )
      response.headers['Surrogate-Key'] = current_website.event.slug if FastlyService.service
      fresh_when(
        current_website,
        last_modified: current_website.purged_at || current_website.updated_at
      ) unless current_website.caching_off?
    end
  end
end
