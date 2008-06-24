class Iteration < ActiveRecord::Base
  has_many :stories

  validates_length_of :title, :within=>1..200
  
  def calculate_end_date
    iter = self
    unpassed_points = Story.find(:all, :conditions=>"state != 'pass'", :select=>'swag').inject(0){|x,y| y.swag ? x+y.swag : 0 }.to_f
    iter.stories.find(:all, :conditions=>"state='pass'").each{|x| unpassed_points+=x.swag if x.swag.to_f}
    all_iters = Iteration.find(:all, :order=>'start_date asc')
    prev_iter = all_iters[all_iters.index(iter)-1]

    if prev_iter.velocity !=0
      return (iter.start_date + (unpassed_points/prev_iter.velocity)*iter.total_days)
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
    ActiveRecord::Base.connection.select_value("select sum(swag) from stories where iteration_id=#{id}").to_f
  end

  def completed_points
    ActiveRecord::Base.connection.select_value("select sum(swag) from stories where iteration_id=#{id} and state='pass'").to_f
  end
  def open_points
    ActiveRecord::Base.connection.select_value("select sum(swag) from stories where iteration_id=#{id} and state!='pass'").to_f
  end
  def total_days
    (end_date - start_date).numerator
  end
  def self.current
    t=Date.today
    Iteration.find(:first, :conditions=>['start_date <= ? and end_date >= ?', t,t])
  end
  def velocity
    stories.find(:all, :conditions=>"state='pass'").inject(0){|x,s| x+(s.swag||0)}.to_f
  end
  
  def previous
    iterations = Iteration.find(:all, :order=>"start_date asc")
    index = iterations.index(self)
    return nil if index < 1
    iterations[index-1]
  end

  
end
