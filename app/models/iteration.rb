# == Schema Information
# Schema version: 20090204043205
#
# Table name: iterations
#
#  id         :integer         not null, primary key
#  title      :string(200)     not null
#  start_date :date            not null
#  end_date   :date            not null
#  created_at :datetime
#  updated_at :datetime
#

class Iteration < ActiveRecord::Base
  has_many :stories
  has_many :bugs    # well...not really...i mean cmon, we dont suck that bad...
  has_and_belongs_to_many :releases

  validates_length_of :title, :within=>1..200
  
  def calculate_end_date
    unpassed_points = Story.sum(:swag, :conditions=>"state != 'passed'")
    if previous && previous.velocity !=0
      return start_date + ((unpassed_points/previous.velocity)*total_days).to_i
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
    (stories.sum('swag') + bugs.sum('swag')).to_f
  end

  def completed_points
    (stories.sum('swag', :conditions=>['state=?','passed']) + bugs.sum('swag', :conditions=>['state=?','passed'])).to_f
  end

  def open_points
    (stories.sum('swag', :conditions=>['state!=?','passed']) + bugs.sum('swag', :conditions=>['state!=?','passed'])).to_f
  end

  def points_in_qc
    (stories.sum('swag', :conditions => {:state => 'in_qc'}) + bugs.sum('swag', :conditions => {:state => 'in_qc'})).to_f
  end

  def ready_points
    (stories.sum('swag', :conditions => {:state => 'new'}) + bugs.sum('swag', :conditions => {:state => 'waiting_for_fix'})).to_f
  end

  def in_progress_points
    (stories.sum('swag', :conditions => {:state => 'in_progress'}) + bugs.sum('swag', :conditions => {:state => 'in_progress'})).to_f
  end

  def total_days
    (end_date - start_date).numerator
  end

  def story_bug_count
    stories.length + bugs.length
  end

  def completed_story_bug_count
    stories.count(:conditions=>['state=?','passed']) + bugs.count(:conditions=>['state=?','passed'])
  end

  def self.current
    t=Date.today
    Iteration.find(:first, :conditions=>["start_date<=? and end_date>=?", t, t])
  end

  def velocity
    completed_points
  end

  def swags_created_on(d)
    (stories.sum('swag', :conditions=>['date(stories.created_at) = date(?)', d]) + 
      bugs.sum('swag', :conditions=>['date(bugs.created_at) = date(?)', d])).to_f
  end

  def stories_bugs_passed_on(d)
    (stories.sum('swag', :conditions=>['stories.state=\'passed\' and date(completed_at)=date(?)', d]) + 
      bugs.sum('swag', :conditions=>['bugs.state=\'passed\' and date(completed_at)=date(?)', d])).to_f
  end
  
  def previous
    @previous ||= Iteration.find :first, :conditions => ['start_date < ?', start_date], :order => 'start_date desc'
  end
  
  def next
    @next ||= Iteration.find :first, :conditions => ['start_date > ?', end_date], :order => 'start_date asc'
  end
end
