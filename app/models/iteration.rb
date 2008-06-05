class Iteration < ActiveRecord::Base
  has_many :stories

  validates_length_of :title, :within=>1..20

  validates_format_of :start_date, :with=>/^[0-9]{4}-[0-9]{2}-[0-9]{2}$/, :allow_nil=>true

  validates_presence_of :start_date

end
