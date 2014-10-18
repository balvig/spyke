require 'spike/associations/association'
require 'spike/path'

module Spike
  module Associations
    class HasMany < Association

      def initialize(*args)
        super
        @params = { foreign_key => owner.try(:id) }
      end

      def activate
        self
      end

      def collection_path
        Path.new owner.class.collection_path, ":#{foreign_key}", klass.collection_path
      end

      def resource_path
        collection_path.join ':id'
      end
    end
  end
end
