module Spyke
  module Associations
    class BelongsTo < Association
      def initialize(*args)
        super
        @options.reverse_merge!(uri: "#{@name.to_s.pluralize}/:#{primary_key}", foreign_key: "#{klass.model_name.element}_id")
        @params[primary_key] = parent.try(foreign_key)
      end
    end
  end
end
