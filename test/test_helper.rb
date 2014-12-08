require 'spyke'
require 'coveralls'
require 'faraday_middleware'
require 'minitest/autorun'
require 'minitest/reporters'
require 'mocha/mini_test'
require 'multi_json'
require 'pry'
require 'webmock/minitest'

# Require support files
Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |f| require f }

# Pretty colors
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

# Coverage
Coveralls.wear!
