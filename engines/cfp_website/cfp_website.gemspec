Gem::Specification.new do |spec|
  spec.name = 'cfp_website'
  spec.version = '0.0.1'
  spec.authors = ['Ruby Central']
  spec.homepage = 'https://github.com/rubycentral/cfp-app'
  spec.summary = 'Beta conference website hosting for cfp-app (optional engine)'
  spec.license = 'MIT'

  spec.files = Dir['{app,config,lib}/**/*', 'README.md']

  spec.add_dependency 'aws-sdk-s3' # ActiveStorage S3 service for the website's uploads
  spec.add_dependency 'fastly'
  spec.add_dependency 'image_processing', '~> 2.2'
  spec.add_dependency 'nokogiri'
end
