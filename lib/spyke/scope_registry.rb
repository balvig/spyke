module Spyke
  class ScopeRegistry
    extend ActiveSupport::PerThreadRegistry

    def initialize
      @registry = Hash.new { |hash, key| hash[key] = {} }
    end

    def value_for(scope_type, variable_name)
      @registry[scope_type][variable_name]
    end

    def set_value_for(scope_type, variable_name, value)
      @registry[scope_type][variable_name] = value
    end
  end
end
