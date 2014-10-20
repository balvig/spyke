require 'spike/associations/association'

module Spike
  module Associations
    class BelongsTo < Association

      def initialize(*args)
        super
        @options.reverse_merge!(foreign_key: "#{klass.model_name.param_key}_id")
        @path_params = { id: parent.try(foreign_key) }
      end

      private

        def default_uri_template
          File.join klass.model_name.plural, ':id'
        end

    end
  end
end
