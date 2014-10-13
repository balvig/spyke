require "active_model"
require 'spike/api'
require 'spike/associations'
require 'spike/attributes'
require 'spike/scopes'

module Spike
  module Base
    extend ActiveSupport::Concern

    include Api
    include Associations
    include Attributes
    include Scopes

    included do
      extend ActiveModel::Translation
    end


    private

      def method_missing(name, *args, &block)
        if has_association?(name)
          build_association(name)
        elsif has_attribute?(name)
          build_attribute(name)
        elsif predicate?(name)
          build_predicate(name)
        else
          super
        end
      end

      def respond_to_missing?(name, include_private = false)
        has_association?(name) || has_attribute?(name) || predicate?(name) || super
      end

  end
end
