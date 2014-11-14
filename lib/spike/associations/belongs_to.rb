module Spike
  module Associations
    class BelongsTo < Association
      def initialize(*args)
        super
        @options.reverse_merge!(uri: "/#{klass.model_name.plural}/:id", foreign_key: "#{klass.model_name.param_key}_id")
        @params[:id] = parent.try(foreign_key)
      end
    end
  end
end
