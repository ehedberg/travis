class Release < ActiveRecord::Base
  has_many :iterations
  validates_length_of :title, :within=>1..75
  
  def self.current
    Iteration.current.release
  end
  
end
