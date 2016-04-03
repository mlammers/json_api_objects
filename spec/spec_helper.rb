$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'bundler'
Bundler.setup

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end

Bundler.require(:default, :test)

require 'json_api_objects'

RSpec.configure do |_config|
  FactoryGirl.find_definitions
end
