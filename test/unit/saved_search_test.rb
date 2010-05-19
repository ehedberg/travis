require File.dirname(__FILE__)+'/../test_helper'

class SavedSearchTest < ActiveSupport::TestCase
  def test_happy
    s = SavedSearch.new(:query=>'foo', :name=>'bars', :query_type=>'Task')
    assert  s.save
  end

  def test_validations
    @model = SavedSearch.new(:query=>'foo', :name=>'bars', :query_type=>'Task')
    assert_invalid(:query, "can't be blank",  nil)
    assert_invalid(:query_type, "can't be blank",  nil)
    assert_invalid(:name, "can't be blank",  nil)
    assert_valid(:name,   'a'*50)
    assert_invalid(:name, "is too short (minimum is 4 characters)", 'abc')
    assert_invalid(:name, "is too long (maximum is 50 characters)", ('a'*51))
    
  end

  def test_find_story_searches
    SavedSearch.for_stories.each do |x|
      assert_equal x.query_type, 'Story'
    end
  end
  def test_validates_unique_name_and_query
    a = SavedSearch.new(:query=>'foo', :name=>'bars', :query_type=>'Task')
    assert a.save
    b = SavedSearch.new(:query=>'foo', :name=>'bars', :query_type=>'Task')
    assert !b.save
    assert_equal "has already been taken", b.errors.on(:name)
    assert_equal "has already been taken", b.errors.on(:query)
    b = SavedSearch.new(:query=>'foo', :name=>'bars', :query_type=>'Story')
    assert b.save
  end

  def test_find_task_searches
    SavedSearch.for_tasks.each do |x|
      assert_equal x.query_type, 'Task'
    end
  end

  def test_find_bug_searches
    SavedSearch.for_bugs.each do |x|
      assert_equal x.query_type, 'Bug'
    end
  end

end

# == Schema Information
# Schema version: 20090612194131
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

