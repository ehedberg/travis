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
    SavedSearch.find_story_searches.each do |x|
      assert_equal x.query_type, 'Story'
    end
  end
  def test_find_task_searches
    SavedSearch.find_task_searches.each do |x|
      assert_equal x.query_type, 'Task'
    end
  end

end
