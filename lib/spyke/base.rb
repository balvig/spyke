require 'active_model'
require 'spyke/associations'
require 'spyke/attribute_assignment'
require 'spyke/orm'
require 'spyke/http'
require 'spyke/scoping'


module Spyke
  class Base
    # ActiveModel
    include ActiveModel::Model

    # Spyke
    include Associations
    include AttributeAssignment
    include Http
    include Orm
    include Scoping
  end
end
