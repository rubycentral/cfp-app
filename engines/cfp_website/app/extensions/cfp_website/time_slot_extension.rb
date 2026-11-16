module CfpWebsite
  module TimeSlotExtension
    extend ActiveSupport::Concern

    included do
      belongs_to :sponsor, optional: true
    end
  end
end
