require 'spike/associations/association'
require 'spike/path'

module Spike
  module Associations
    class HasMany < Association

      def initialize(*args)
        super
        @path_params = { foreign_key => parent.try(:id) }
      end

      def activate
        self
      end

      def uri_template
        File.join parent.class.model_name.plural, ":#{foreign_key}", klass.model_name.plural, ':id'
      end

      def new(attributes = {})
        super attributes.merge(@path_params)
      end

    end
  end
end
