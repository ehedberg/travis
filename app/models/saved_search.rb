class SavedSearch < ActiveRecord::Base
  validates_presence_of :query, :query_type, :name
  validates_length_of :name,  :in => 4..50

  def self.find_story_searches
    find(:all, :conditions=>"query_type='Story'")
  end
  def self.find_task_searches
    find(:all, :conditions=>"query_type='Task'")
  end
end
