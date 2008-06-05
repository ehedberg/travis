class Story < ActiveRecord::Base
  has_and_belongs_to_many :tasks

  belongs_to :iteration

  validates_numericality_of :swag, :greater_than_or_equal_to=>0, :allow_nil=>true, :less_than=>10000

  validates_length_of :description, :maximum=>200, :allow_nil=>true

  validates_length_of :title, :within=>1..20
end
