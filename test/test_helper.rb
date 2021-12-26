require 'simplecov'
require 'simplecov-lcov'
SimpleCov::Formatter::LcovFormatter.config do |c|
  c.report_with_single_file = true
  c.single_report_path = 'coverage/lcov.info'
end
SimpleCov.formatter = SimpleCov::Formatter::LcovFormatter
SimpleCov.start do
  add_filter 'test'
end

require 'spyke'
require 'minitest/autorun'
require 'minitest/reporters'
require 'mocha/minitest'
require 'pry'

# Require support files
Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |f| require f }

# Pretty colors
Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

# For testing strong params
require 'action_controller/metal/strong_parameters'

def strong_params(params)
  ActionController::Parameters.new(params)
end
