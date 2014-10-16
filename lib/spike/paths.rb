module Spike
  module Paths
    extend ActiveSupport::Concern

    module ClassMethods
      def collection_path
        base_path
      end

      def resource_path
        File.join base_path, ':id'
      end

      def base_path
        model_name.route_key
      end
    end
  end
end
