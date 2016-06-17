module Spyke
  module Associations
    class BelongsTo < Association
      def initialize(*args)
        super
        @options.reverse_merge!(uri: "#{@name.to_s.pluralize}/:#{id_key}", foreign_key: "#{klass.model_name.element}_id")
        @params[id_key] = parent.try(foreign_key)
      end
    end
  end
end
