module Spyke
  class ScopeRegistry
    # https://github.com/balvig/spyke/pull/128
    if ActiveSupport::VERSION::MAJOR >= 7
      class << self
        delegate :value_for, :set_value_for, to: :instance

        def instance
          ActiveSupport::IsolatedExecutionState[:spyke_scope_registry] ||= new
        end
      end
    else
      extend ActiveSupport::PerThreadRegistry
    end

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
