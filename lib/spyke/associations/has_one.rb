module Spyke
  module Associations
    class HasOne < Association
      def initialize(*args)
        super
        @options.reverse_merge!(uri: "#{parent.class.model_name.plural}/:#{foreign_key}/#{@name}")
        @params[foreign_key] = parent.id unless embed_only?
      end
    end
  end
end
