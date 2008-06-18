require File.dirname(__FILE__)+'/../test_helper'

class SavedSearchesControllerTest < ActionController::TestCase

  def test_routing
    do_default_routing_tests('saved_searches')
  end
  def test_create_tasksearch
    c = SavedSearch.for_tasks.size
    xhr :post, :create, :saved_search=>{:name=>'fubar2', :query=>"swhere state='new'", :query_type=>'Task'}
    assert_response :success
    assert assigns(:saved_search)
    assert_equal assigns(:saved_search).query_type, 'Task'
    assert !assigns(:saved_search).new_record?
    assert_equal SavedSearch.for_tasks.size, c+1
    assert_select_rjs  'savedSearches' do
        assert_select "li" do 
        assert_select "a",'fubar2'
      end
    end
  end

  def test_create_storyesearch
    c = SavedSearch.for_stories.size
    xhr :post, :create, :saved_search=>{:name=>'fubar', :query=>"where state='new'", :query_type=>'Story'}
    assert_response :success
    assert assigns(:saved_search)
    assert !assigns(:saved_search).new_record?
    assert_equal SavedSearch.for_stories.size, c+1
    assert_select_rjs  'savedSearches' do
        assert_select "li" do 
        assert_select "a",'fubar'
      end
    end
  end
  def test_destroy_story
    xhr :delete, :destroy, :id=>saved_searches(:story_1).id
    assert_response :success
    assert !SavedSearch.exists?(saved_searches(:story_1).id)
  end
  def test_destroy_task
    xhr :delete, :destroy, :id=>saved_searches(:task_1).id
    assert_response :success
    assert !SavedSearch.exists?(saved_searches(:task_1).id)
  end
end
