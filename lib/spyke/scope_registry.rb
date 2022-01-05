module Spyke
  module ScopeRegistry
    extend self

    def value_for(scope_type, variable_name)
      registry[scope_type][variable_name]
    end

    def set_value_for(scope_type, variable_name, value)
      registry[scope_type][variable_name] = value
    end

    private

    def registry
      Thread.current[to_s] ||= Hash.new { |hash, key| hash[key] = {} }
    end
  end
end
