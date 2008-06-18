class SavedSearch < ActiveRecord::Base
  validates_presence_of :query, :query_type, :name
  validates_length_of :name,  :in => 4..50
end
