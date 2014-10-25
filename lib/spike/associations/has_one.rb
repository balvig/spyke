require 'spike/associations/association'

module Spike
  module Associations
    class HasOne < Association

      def initialize(*args)
        super
        @options[:uri_template] ||= "/#{parent.class.model_name.plural}/:#{foreign_key}/#{klass.model_name.singular}"
        @params[foreign_key] = parent.id
      end

    end
  end
end
