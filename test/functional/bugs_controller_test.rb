require File.dirname(__FILE__) + '/../test_helper'

class BugsControllerTest < ActionController::TestCase

  def setup
    @request.session[:user_id]=1
  end

  def test_routes
    do_default_routing_tests('bugs')
  end

  def test_index
    get :index
    assert(assigns(:bugs))
    assert_response :success
    assert_template 'bugs/index'
  end

  def test_requires_login
    @request.session[:user_id]=nil
    get :index
    assert_response :redirect
    assert_redirected_to new_session_path
    @request.session[:user_id]=1
    get :index
    assert_response :success
    assert_template 'bugs/index'
  end

  def test_new
    get :new
    assert_response :success
    assert_template "form"
    assert assigns(:bug)
    assert assigns(:bug).new_record?
    assert_select "form[action=?][method=post]", bugs_path
  end
  
  def test_create
    post :create, "bug"=>{"title"=>"New Title", "description"=>"desc", "swag"=>"2"}
    assert bug = assigns(:bug)
    assert_equal Bug.find_by_description("desc"), bug
    assert_response :redirect
    assert_redirected_to bug_path(bug)
  end

  def test_edit
    get :edit, :id=>bugs(:one).id
    assert bug = assigns(:bug)
    assert_equal bugs(:one).id, bug.id
    assert_response :success
    assert_template 'bugs/form'
  end

  def test_update
    bug = bugs(:one)
    put :update, :id=>bug.id, :bug=>{:title=>"New title", :description=>"New Description", :swag=>"9999.99" }
    new_bug = Bug.find(bug.id)
    assert_equal "New title", new_bug.title
    assert_equal "New Description", new_bug.description
    assert_equal 9999.99, new_bug.swag
    assert assigns(:bug)
    assert_redirected_to bug_path(assigns(:bug))
    assert_not_equal :fubar, new_bug.current_state
  end

  def test_update_fires_event
    bug = bugs(:one)
    bug.reload
    assert_equal :waiting_for_fix, bug.current_state
    put :update, :id=>bug.id, :bug=> {:title=>"New title", :description=>"New Description", :swag=>"9999.99", :state=>'start'}
    new_bug = Bug.find(bug.id)
    assert_equal "New title", new_bug.title
    assert_equal "New Description", new_bug.description
    assert_equal 9999.99, new_bug.swag
    assert_redirected_to bug_path(assigns(:bug))
    assert_equal :in_progress, new_bug.current_state
  end

  def test_update_invalid_title
    bug = bugs(:one)
    put :update, :id=>bug.id, :bug=>{:title=>"", :description=>"New Description", :swag=>"9999.99" }
    assert_response :success
    assert_template "bugs/form"
    new_bug = Story.find(bug.id)
    b = assigns(:bug)
    assert_equal b.errors.on(:title), "is too short (minimum is 4 characters)"
    assert_select "div[id=errorExplanation][class=errorExplanation]"
  end

  def test_show
    get :show, :id=>bugs(:one).id
    assert bug = assigns(:bug)
    assert_equal assigns(:bug), bugs(:one)
    assert_template "show"
    assert_select "a[href=?]", iteration_path(bugs(:one).iteration), :text=>"#{bugs(:one).iteration.title}"
    assert_select "a[href=?]", bugs_path
    assert_select "a[href=?]", edit_bug_path(bugs(:one).id)
    assert_select "a[href=?][onclick*=confirm]", bug_path(bugs(:one))
  end

  def test_destroy_bug_not_in_iteration
    bug = bugs(:three)
    delete :destroy, :id=>bugs(:three).id
    assert !Bug.exists?(bug.id)
    assert_redirected_to bugs_path
  end

  def test_destroy_bug_in_iteration
    bug = bugs(:one)
    assert_equal(iterations(:iter_current), bug.iteration)
    delete :destroy, :id=>bugs(:one).id
    assert !Bug.exists?(bug.id)
    assert_redirected_to iteration_path(iterations(:iter_current))
  end

  def test_update_swag
    xhr :post, :update_swag, "id"=>bugs(:one).id, "value"=>"2.1\n", "controller"=>"bugs", "editorId"=>"swag_1"
    assert_response :success
    assert_equal "2.1", @response.body
  end
  
  def test_update_tags
    xhr :post, :update_tags, "id"=>bugs(:one).id, "value"=>"your mom", "controller"=>"bugs", "editorId"=>"swag_1"
    assert_response :success
    assert_equal 'your mom', @response.body
  end

  def test_show_history_link
    assert_routing "/bugs/1/history", {:action=>"history", :controller=>"bugs", :id=>"1"}
    get :show, :id=>bugs(:one).id
    assert assigns(:bug)
    assert_not_nil assigns(:bug).audit_records
    assert_equal assigns(:bug), bugs(:one)
    assert_template "show"
    assert_select "a[href=#]"
  end

  def test_search_view
    assert_routing({:path=>"/bugs/search", :method=>'get'}, :controller=>'bugs', :action=>'search')
    get :search
    assert_response :success
    assert_template 'search'
    assert assigns(:saved_searches)
    assigns(:saved_searches).each do |x|
      assert_equal x.query_type, 'Bug'
    end
    assert_select "ul#savedSearches" do 
        assert_select "li", SavedSearch.for_bugs.size  do
          assert_select "a[href=#]"
      end
    end
  end

  def test_do_tag_search
    s = bugs(:one)
    s.tag_list.add('abc')
    s.save!

    assert_routing({:path=>"/bugs/do_search",:method=>'post'}, :controller=>'bugs', :action=>'do_search')
    xhr :post, :do_search, "tagsearch"=>"1", "expr"=>"abc"

    assert_response :success
    assert assigns(:bugs)
    ts = assigns(:bugs)
    assert_equal 1, ts.size
    assert_equal 'abc', ts.first.tag_list.first
    assert_select_rjs  'results'
    assert_select_rjs :replace_html, "saveform" do
      assert_select "form[action=?]", saved_searches_path do
        assert_select 'input[type=hidden][id=saved_search_query]'
        assert_select 'input[type=hidden][id=saved_search_query_type]'
        assert_select 'input[type=text][id=saved_search_name]'
        assert_select "input[type=submit]"
      end
    end
  end

  def test_do_search
    xhr :post, :do_search, :expr=>"state in ('new', 'waiting_for_fix')"
    assert_response :success
    assert assigns(:bugs)
    ts = assigns(:bugs)
    ts.each do |t|
      assert(t.current_state == :new || t.current_state == :waiting_for_fix)
    end
    assert_equal 2, ts.size
    assert_select_rjs  'results'
    assert_select_rjs :replace_html, "saveform" do
      assert_select "form[action=?]", saved_searches_path do
        assert_select 'input[type=hidden][id=saved_search_query]'
        assert_select 'input[type=hidden][id=saved_search_query_type]'
        assert_select 'input[type=text][id=saved_search_name]'
        assert_select "input[type=submit]"
      end
    end
  end

  def test_mass_tag
    b1 = bugs(:one)
    b2 = bugs(:two)
    b2.tag_list.add("foo")
    b2.save!
    assert_routing({:method=>'post', :path=>'/bugs/mass_tag'}, :controller=>'bugs', :action=>'mass_tag')
    post :mass_tag, :ids=>[b2.id, b1.id], :tags=>'some, dumb, tag'
    assert_response :success
    b1.reload
    b2.reload
    assert_equal %w(some dumb tag), b1.tag_list
    assert_equal %w(foo some dumb tag), b2.tag_list
  end

end
