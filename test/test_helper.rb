# Coverage
require 'coveralls'
Coveralls.wear!
SimpleCov.formatter = Coveralls::SimpleCov::Formatter
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
