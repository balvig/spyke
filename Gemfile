source 'https://rubygems.org'

# Specify your gem's dependencies in spyke.gemspec
gemspec

if ENV['FARADAY_TEST_VERSION'] == '< 2.0'
  gem 'faraday_middleware'
end

# https://github.com/ruby/bigdecimal#which-version-should-you-select
if ENV['RAILS_TEST_VERSION'] == '~> 4.0'
  gem 'bigdecimal', '1.3.5'
end
