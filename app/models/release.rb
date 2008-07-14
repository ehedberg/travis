class Release < ActiveRecord::Base
  has_and_belongs_to_many :iterations, :order=>"start_date asc"
  validates_length_of :title, :within=>1..75
  has_many :stories, :through=>:iterations
  
  def self.current
    Iteration.current.release
  end
  def swags_created_on(d)
    stories.find(:all, :conditions=>['stories.created_at = ?', d]).map{|x| x.swag ? x.swag : 0.0}
  end
  def stories_passed_on(d)
    s = stories.find(:all, :conditions=>['stories.state=\'passed\' and date(completed_at)=date(?)', d])
    s.map{|x| x.swag ? x.swag : 0.0}
  end
  def total_points
    @tswag||=stories.map(&:swag).compact.sum
  end
  def total_days
    @tdays||=iterations.map(&:total_days).compact.sum
  end
  def open_points
    iterations.map{|x|x.open_points}.sum
  end
  def story_count 
    iterations.map{|x|x.story_count}.sum
  end
  
  def completed_story_count 
    iterations.map{|x|x.completed_story_count}.sum
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
