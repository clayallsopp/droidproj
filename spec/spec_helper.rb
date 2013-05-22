require 'rspec'
require_relative '../lib/droidproj'

DroidProj::Logger.logger.enabled = false

SPEC_RESOURCES = File.join(File.dirname(__FILE__), 'resources')

RSpec.configure do |config|
  config.color_enabled = true
  config.formatter     = 'documentation'
end