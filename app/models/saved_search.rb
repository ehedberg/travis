class SavedSearch < ActiveRecord::Base
  validates_presence_of :query, :query_type, :name
  validates_length_of :name,  :in => 4..50
  validates_uniqueness_of :name, :scope=>:query_type
  validates_uniqueness_of :query, :scope=>:query_type

  named_scope :for_stories, :conditions=>['query_type=?','Story']
  named_scope :for_tasks, :conditions=>['query_type=?','Task']
end
