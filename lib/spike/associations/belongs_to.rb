require 'spike/associations/association'
require 'spike/path'

module Spike
  module Associations
    class BelongsTo < Association

      def initialize(*args)
        super
        @options.reverse_merge!(foreign_key: "#{klass.model_name.param_key}_id")
        @params = { id: owner.try(foreign_key) }
      end

      def resource_path
        Path.new klass.model_name.plural, ':id'
      end

    end
  end
end
