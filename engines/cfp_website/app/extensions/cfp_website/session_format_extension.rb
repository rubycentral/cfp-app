module CfpWebsite
  module SessionFormatExtension
    extend ActiveSupport::Concern

    included do
      has_one :session_format_config
    end
  end
end
