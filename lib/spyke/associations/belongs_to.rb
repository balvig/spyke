module Spyke
  module Associations
    class BelongsTo < Association
      def initialize(*args)
        super
        @options.reverse_merge!(uri: "#{@name.to_s.pluralize}/:#{primary_key}", foreign_key: "#{klass.model_name.element}_id")
        @params[primary_key] = primary_key_value
      end

      def find_one
        return unless fetchable?
        super
      end

      private

        def fetchable?
          (primary_key_value || embedded_data).present?
        end

        def primary_key_value
          parent.try(foreign_key)
        end
    end
  end
end
