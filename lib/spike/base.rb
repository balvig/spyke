require 'active_model'
require 'spike/associations'
require 'spike/attributes'
require 'spike/orm'
require 'spike/paths'
require 'spike/http'

module Spike
  module Base
    extend ActiveSupport::Concern

    # Spike
    include Associations
    include Attributes
    include Http
    include Orm
    include Paths

    # ActiveModel
    include ActiveModel::Conversion

    included do
      extend ActiveModel::Translation
    end

    private

      def method_missing(name, *args, &block)
        if has_association?(name)
          get_association(name)
        elsif has_attribute?(name)
          get_attribute(name)
        elsif predicate?(name)
          get_predicate(name)
        elsif setter?(name)
          set_attribute(name, args.first)
        else
          super
        end
      end

      def respond_to_missing?(name, include_private = false)
        has_association?(name) || has_attribute?(name) || predicate?(name) || super
      end

  end
end
