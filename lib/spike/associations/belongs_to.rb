require 'spike/associations/association'

module Spike
  module Associations
    class BelongsTo < Association

      def initialize(*args)
        super
        @options[:foreign_key] ||= "#{klass.model_name.param_key}_id"
        @options[:uri_template] ||= File.join '/', klass.model_name.plural, ':id'
        @params[:id] = parent.try(foreign_key)
      end

    end
  end
end
