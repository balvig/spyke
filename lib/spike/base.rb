require 'active_model'
require 'spike/associations'
require 'spike/attributes'
require 'spike/orm'
require 'spike/http'

module Spike
  class Base
    #extend ActiveSupport::Concern

    # Spike
    include Associations
    include Attributes
    include Http
    include Orm

    # ActiveModel
    include ActiveModel::Conversion
    extend ActiveModel::Translation

    #included do
      #extend ActiveModel::Callbacks
    #end

  end
end
