require 'spyke/collection'
require 'spyke/attributes'

module Spyke
  module AttributeAssignment
    extend ActiveSupport::Concern

    included do
      attr_reader :attributes
      delegate :[], :[]=, to: :attributes
    end

    module ClassMethods
      # By adding instance methods via an included module,
      # they become overridable with "super".
      # http://thepugautomatic.com/2013/07/dsom/
      def attributes(*names)
        unless @spyke_instance_method_container
          @spyke_instance_method_container = Module.new
          include @spyke_instance_method_container
        end

        @spyke_instance_method_container.module_eval do
          names.each do |name|
            define_method(name) do
              attribute(name)
            end
          end
        end
      end
    end

    def initialize(attributes = {})
      self.attributes = attributes
      @uri_template = scope.uri
      yield self if block_given?
    end

    def attributes=(new_attributes)
      @attributes ||= Attributes.new(scope.params)
      use_setters(new_attributes) if new_attributes
    end

    def id
      attributes[self.class.id_key]
    end

    def id=(value)
      attributes[self.class.id_key] = value if value.present?
    end

    def hash
      id.hash
    end

    def ==(other)
      other.instance_of?(self.class) && id? && id == other.id
    end
    alias :eql? :==

    def inspect
      "#<#{self.class}(#{@uri_template}) id: #{id.inspect} #{inspect_attributes}>"
    end

    def as_json(options = nil)
      attributes.as_json(options)
    end

    private

      def use_setters(attributes)
        # NOTE: special treatment for :id key, a resource can be identified by
        # :id or by user defined id_key (default is :id) but in the case where
        # both id_key and ':id' are passed, :id is treated as attribute
        # independent of id_key and  primary_key will be id_key
        # user can acess the data in :id using resource[:id]

        if conflicting_ids?(attributes)
          id_key = self.class.id_key
          @attributes[:id] = attributes.delete(:id)
          @attributes[id_key] = attributes.delete(id_key)
        end

        attributes.each do |key, value|
          send "#{key}=", value
        end
      end

      def conflicting_ids?(attributes)
        id_key = self.class.id_key
        id_key != :id &&
          attributes.key?(:id) &&
          attributes.key?(id_key)
      end

      def method_missing(name, *args, &block)
        case
        when association?(name) then association(name).load
        when attribute?(name)   then attribute(name)
        when predicate?(name)   then predicate(name)
        when setter?(name)      then set_attribute(name, args.first)
        else super
        end
      end

      def respond_to_missing?(name, include_private = false)
        association?(name) || attribute?(name) || predicate?(name) || super
      end

      def association?(name)
        associations.has_key?(name)
      end

      def association(name)
        associations[name].build(self)
      end

      def attribute?(name)
        attributes.has_key?(name)
      end

      def attribute(name)
        attributes[name]
      end

      def predicate?(name)
        name.to_s.end_with?('?')
      end

      def predicate(name)
        !!attribute(depredicate(name))
      end

      def depredicate(name)
        name.to_s.chomp('?').to_sym
      end

      def setter?(name)
        name.to_s.end_with?('=')
      end

      def set_attribute(name, value)
        attributes[name.to_s.chomp('=')] = value
      end

      def inspect_attributes
        attributes.except(self.class.id_key).map { |k, v| "#{k}: #{v.inspect}" }.join(' ')
      end
  end
end
