class Iteration < ActiveRecord::Base
  has_many :stories

  validates_length_of :title, :within=>1..200
  
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
    ActiveRecord::Base.connection.select_value("select sum(swag) from stories where iteration_id=#{id} and state='passed'").to_f
  end
  def open_points
    ActiveRecord::Base.connection.select_value("select sum(swag) from stories where iteration_id=#{id} and state!='passed'").to_f
  end
  def total_days
    (end_date - start_date).numerator
  end
  def self.current
    t=Date.today
    Iteration.find(:first, :conditions=>['start_date <= ? and end_date >= ?', t,t])
  end
  def velocity
    stories.inject(0){|x,y| x+y.swag}.to_f
  end

  
end
