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
  end
  
end
