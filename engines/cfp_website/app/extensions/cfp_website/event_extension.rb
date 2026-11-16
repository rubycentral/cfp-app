module CfpWebsite
  module EventExtension
    extend ActiveSupport::Concern

    included do
      has_many :sponsors
      has_one :website
    end
  end
end
