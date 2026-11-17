# Whether the optional website engine (engines/cfp_website) is enabled.
#
# Plain Ruby with no Rails dependency, because both the Gemfile (to install the
# engine's gems) and config/application.rb (to load the engine) read it, and the
# two must never disagree. 0/false/f/off/blank/unset keep it off, in any case;
# anything else, such as 1 or true, turns it on.
module CfpApp
  WEBSITE_FLAG_FALSE_VALUES = %w[0 f false off].freeze

  def self.website_enabled?
    value = ENV['ENABLE_WEBSITE'].to_s.strip.downcase
    !value.empty? && !WEBSITE_FLAG_FALSE_VALUES.include?(value)
  end
end
