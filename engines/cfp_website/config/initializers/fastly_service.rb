class FastlyService
  include Singleton

  attr_reader :service

  def initialize
    if ENV['FASTLY_API_KEY']
      fastly  = Fastly.new(api_key: ENV['FASTLY_API_KEY'])
      @service = Fastly::Service.new({ id: ENV['FASTLY_SERVICE_ID'] }, fastly)
    end
  end

  def self.service
    self.instance.service
  end
end
