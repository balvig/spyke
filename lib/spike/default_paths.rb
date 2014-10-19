#require 'spike/path'

module Spike
  module DefaultPaths
    extend ActiveSupport::Concern

    module ClassMethods
      def collection_path
        Path.new model_name.plural
      end

      def resource_path
        collection_path.join ':id'
      end
    end
  end
end
