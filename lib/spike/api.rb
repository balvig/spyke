require 'spike/request'
require 'spike/collection'

module Spike
  module Api
    extend ActiveSupport::Concern

    module ClassMethods
      def collection_path
        "/recipes#{current_scope.to_query}"
      end

      def resource_path(id)
        "/recipes/#{id}"
      end

      def get_resource(id)
        request = Request.new(:get, resource_path(id))
        new request.data
      end

      def get_collection
        request = Request.new(:get, collection_path)
        Collection.new request.data.map { |record| new(record) }, request.metadata
      end

    end
  end
end
