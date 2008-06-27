class Release < ActiveRecord::Base
  has_many :iterations, :order=>"start_date asc"
  validates_length_of :title, :within=>1..75
  
  def self.current
    Iteration.current.release
  end
  
  def start_date
    if has_iterations?
      iterations.first.start_date
    else
      "No start iteration"
    end
  end
  def end_date
    if has_iterations?
      iterations.last.end_date
    else
      "No end iteration"
    end
  end
  
  def has_iterations?
    !iterations.empty?
  end
  
end
