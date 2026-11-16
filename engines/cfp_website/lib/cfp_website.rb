require 'active_storage/engine'
require 'aws-sdk-s3'
require 'fastly'
require 'image_processing'
require 'nokogiri'

require 'cfp_website/engine'

module CfpWebsite
  # ActiveStorage service per Rails environment (see config/storage.yml here).
  STORAGE_SERVICES = {'development' => :local, 'test' => :test, 'production' => :amazon}.freeze
end
