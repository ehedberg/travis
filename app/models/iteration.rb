class Iteration < ActiveRecord::Base
  has_many :stories
  has_and_belongs_to_many :release

  validates_length_of :title, :within=>1..200
  
  def calculate_end_date
    unpassed_points = Story.find(:all, :conditions=>"state != 'passed'", :select=>'swag').map{|x| x.swag.to_f}.sum
    prev_iter = self.previous
    if prev_iter.velocity !=0
      return self.start_date + ((unpassed_points/prev_iter.velocity)*self.total_days)
    else
      "~(never - 1)"
    end

  end
  def validate
    begin
      Date.parse(start_date_before_type_cast)
    rescue
      errors.add(:start_date, "is an invalid date format")
    end
    begin
      Date.parse(end_date_before_type_cast)
    rescue
      errors.add(:end_date, "is an invalid date format")
    end

    errors.add(:start_date, "must be before the end date") if (start_date && end_date)&&(start_date > end_date)
  end

  def total_points
    @totalp||=stories.find(:all).map{|x| x.swag ? x.swag : 0.0}.sum
  end

  def completed_points
    @completedp||=stories.find(:all, :conditions=>['state=?','passed']).map{|x| x.swag ? x.swag : 0.0}.sum
  end
  def open_points
    @openp||=stories.find(:all, :conditions=>['state!=?','passed']).map{|x| x.swag ? x.swag : 0.0}.sum
  end
  def total_days
    (end_date - start_date).numerator
  end
  def story_count
    stories.length
  end
  def completed_story_count
    @compls||=stories.find(:all, :conditions=>['state=?','passed']).size
  end
  def self.current
    t=Date.today
    Iteration.find(:first, :conditions=>["start_date<=? and end_date>=?", t, t])
  end
  def velocity
    stories.find(:all, :conditions=>"state='passed'").map(&:swag).sum
  end
  def swags_created_on(d)
    stories.find(:all, :conditions=>['stories.created_at = ?', d]).map{|x| x.swag ? x.swag : 0.0}
  end
  def stories_passed_on(d)
    s = stories.find(:all, :conditions=>['stories.state=\'passed\' and date(completed_at)=date(?)', d])
    s.map{|x| x.swag ? x.swag : 0.0}
  end
  
  def previous
    iterations = Iteration.find(:all, :order=>"start_date asc")
    index = iterations.index(self)
    return nil if index < 1
    iterations[index-1]
  end

  
end
