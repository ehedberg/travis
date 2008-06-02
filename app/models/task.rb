class Task < ActiveRecord::Base
  has_and_belongs_to_many :stories
  validates_presence_of :description, :title
end
