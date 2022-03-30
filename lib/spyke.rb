require 'active_support'
require 'active_support/core_ext'

require 'faraday'
require 'faraday/multipart'

if Gem.loaded_specs["faraday"].version < Gem::Version.new("2.0")
  begin
    require 'faraday_middleware'
  rescue LoadError => e
    puts <<~MSG
      Please add `faraday_middleware` to your Gemfile when using Faraday 1.x. Alternatively,
      upgrade to Faraday `~> 2` to avoid this dependency.
    MSG
    raise e
  end
end

require 'spyke/base'
require 'spyke/instrumentation' if defined?(Rails)
require 'spyke/version'

module Spyke
end
