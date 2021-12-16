module Spyke
  module Associations
    class Builder
      def initialize(parent_class, name, type, options = {})
        @parent_class, @name, @type, @options = parent_class, name, type, options
      end

      def build(parent)
        @type.new(klass, parent, @name, @options)
      end

      def klass
        @klass ||= custom_class || compute_class(@name)
      end

      private

        def custom_class
          @options[:class_name].constantize if @options[:class_name]
        end

        # https://github.com/rails/rails/blob/70ac072976c8cc6f013f0df3777e54ccae3f4f8c/activerecord/lib/active_record/inheritance.rb#L132-L150
        def compute_class(type_name)
          parent_name = @parent_class.to_s
          type_name = type_name.to_s.classify

          candidates = []
          parent_name.scan(/::|$/) { candidates.unshift "#{$`}::#{type_name}" }
          candidates << type_name

          candidates.each do |candidate|
            constant = safe_constantize(candidate)
            return constant if candidate == constant.to_s
          end
          raise NameError.new("uninitialized constant #{candidates.first}", candidates.first)
        end

        # ActiveSupport < 7.0
        if ActiveSupport::Dependencies.respond_to?(:safe_constantize)
          def safe_constantize(name)
            ActiveSupport::Dependencies.safe_constantize(name)
          end
        # ActiveSupport >= 7.0
        else
          def safe_constantize(name)
            ActiveSupport::Inflector.safe_constantize(name)
          end
        end
    end
  end
end
