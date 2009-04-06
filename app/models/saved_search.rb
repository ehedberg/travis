# == Schema Information
# Schema version: 20090204043205
#
# Table name: saved_searches
#
#  id         :integer         not null, primary key
#  query      :string(200)     not null
#  name       :string(50)      not null
#  query_type :string(10)      not null
#  created_at :datetime
#  updated_at :datetime
#

class SavedSearch < ActiveRecord::Base
  validates_presence_of :query, :query_type, :name
  validates_length_of :name,  :in => 4..50
  validates_uniqueness_of :name, :scope=>:query_type
  validates_uniqueness_of :query, :scope=>:query_type

  named_scope :for_stories, :conditions=>['query_type=?','Story']
  named_scope :for_tasks, :conditions=>['query_type=?','Task']
end
