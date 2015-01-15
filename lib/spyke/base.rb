require 'active_model'
require 'spyke/associations'
require 'spyke/attribute_assignment'
require 'spyke/orm'
require 'spyke/http'
require 'spyke/scoping'


module Spyke
  class Base
    # ActiveModel
    include ActiveModel::Conversion
    include ActiveModel::Model
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks
    extend ActiveModel::Translation
    extend ActiveModel::Callbacks

    # Spyke
    include Associations
    include AttributeAssignment
    include Http
    include Orm
    include Scoping
  end
end
