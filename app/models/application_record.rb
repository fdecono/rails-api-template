class ApplicationRecord < ActiveRecord::Base
  include Serializable
  primary_abstract_class
end
