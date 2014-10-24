module Spike
  class ScopeRegistry # :nodoc:
    extend ActiveSupport::PerThreadRegistry

    def initialize
      @registry = Hash.new { |hash, key| hash[key] = {} }
    end

    # Obtains the value for a given +scope_name+ and +variable_name+.
    def value_for(scope_type, variable_name)
      @registry[scope_type][variable_name]
    end

    # Sets the +value+ for a given +scope_type+ and +variable_name+.
    def set_value_for(scope_type, variable_name, value)
      @registry[scope_type][variable_name] = value
    end
  end
end
