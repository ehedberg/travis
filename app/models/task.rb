class Task < ActiveRecord::Base
  has_and_belongs_to_many :stories
  validates_presence_of :description, :title
  validates_length_of :title, :maximum=>200, :allow_nil=>true
end
