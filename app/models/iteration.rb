class Iteration < ActiveRecord::Base
  has_many :stories

  validates_length_of :title, :within=>1..20

  validates_presence_of :start_date

  validates_presence_of :end_date

  validates_format_of :start_date, :with=>/\A[0-9]{4}-[0-9]{2}-[0-9]{2}\Z/, :allow_nil=>true
end
