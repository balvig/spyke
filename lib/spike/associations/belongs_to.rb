require 'spike/associations/association'

module Spike
  module Associations
    class BelongsTo < Association
      def resource_path
        File.join klass.model_name.plural, :id
      end
    end
  end
end
