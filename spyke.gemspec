# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'spyke/version'

Gem::Specification.new do |spec|
  spec.name          = "spyke"
  spec.version       = Spyke::VERSION
  spec.authors       = ["Jens Balvig"]
  spec.email         = ["jens@balvig.com"]
  spec.summary       = %q{Interact with REST services in an ActiveRecord-like manner}
  spec.description   = %q{Interact with REST services in an ActiveRecord-like manner}
  spec.homepage      = "https://github.com/balvig/spyke"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.6'

  spec.add_dependency 'activesupport', ENV.fetch('RAILS_TEST_VERSION', '>= 4.0.0')
  spec.add_dependency 'activemodel', ENV.fetch('RAILS_TEST_VERSION', '>= 4.0.0')
  spec.add_dependency 'faraday', ENV.fetch('FARADAY_TEST_VERSION', '>= 1.0.0'), '< 3.0'
  spec.add_dependency 'faraday-multipart', '~> 1.0'
  spec.add_dependency 'addressable', '>= 2.5.2'

  spec.add_development_dependency 'actionpack', ENV.fetch('RAILS_TEST_VERSION', '>= 4.0.0')
  spec.add_development_dependency 'bundler', '>= 1.6'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'minitest-line'
  spec.add_development_dependency 'minitest-reporters'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'multi_json'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'simplecov-lcov'
  spec.add_development_dependency 'webmock'
end
