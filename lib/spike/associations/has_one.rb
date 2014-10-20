require 'spike/associations/association'

module Spike
  module Associations
    class HasOne < Association

      def initialize(*args)
        super
        @path_params = { foreign_key => parent.try(:id) }
      end

      private

        def default_uri_template
          File.join parent.class.model_name.plural, ":#{foreign_key}", klass.model_name.singular
        end

    end
  end
end
