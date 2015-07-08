require 'bundler/setup'
Bundler.setup

require 'mdexport'

RSpec.configure do |config|
  config.pattern = 'tests/*_spec*'
end
