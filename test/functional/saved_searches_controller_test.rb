require File.dirname(__FILE__)+'/../test_helper'

class SavedSearchesControllerTest < ActionController::TestCase

  def test_routing
    do_default_routing_tests('saved_searches')
  end

  def test_create_storyesearch
    c = SavedSearch.count
    post :create, :saved_search=>{:name=>'fubar', :query=>"where state='new'", :query_type=>'Story'}
    assert_response :redirect
    assert assigns(:saved_search)
    assert !assigns(:saved_search).new_record?
    assert_redirected_to search_stories_path 
    assert_equal SavedSearch.count, c+1
  end
  def test_create_tasksearch
    c = SavedSearch.count
    post :create, :saved_search=>{:name=>'fubar', :query=>"where state='new'", :query_type=>'Task'}
    assert_response :redirect
    assert assigns(:saved_search)
    assert !assigns(:saved_search).new_record?
    assert_redirected_to search_tasks_path 
    assert_equal SavedSearch.count, c+1
  end
  def test_destroy_story
    delete :destroy, :id=>saved_searches(:story_1).id
    assert_response :redirect
    assert !SavedSearch.exists?(saved_searches(:story_1).id)
    assert_redirected_to search_stories_path 
  end
  def test_destroy_task
    delete :destroy, :id=>saved_searches(:task_1).id
    assert_response :redirect
    assert !SavedSearch.exists?(saved_searches(:task_1).id)
    assert_redirected_to search_tasks_path 
  end
end
