require 'active_model'
require 'spike/associations'
require 'spike/attributes'
require 'spike/scopes'

module Spike
  module Base
    extend ActiveSupport::Concern

    # Spike
    include Associations
    include Attributes
    include Scopes

    # ActiveModel
    include ActiveModel::Conversion

    included do
      extend ActiveModel::Translation
    end

    module ClassMethods
      def collection_path
        base_path
      end

      def resource_path
        "#{base_path}/:id"
      end

      def base_path
        "/#{model_name.route_key}"
      end
    end

    private

      def method_missing(name, *args, &block)
        if has_association?(name)
          get_association(name)
        elsif has_attribute?(name)
          get_attribute(name)
        elsif predicate?(name)
          get_predicate(name)
        else
          super
        end
      end

      def respond_to_missing?(name, include_private = false)
        has_association?(name) || has_attribute?(name) || predicate?(name) || super
      end

  end
end
