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

  def test_destroy
    bug = bugs(:one)
    delete :destroy, :id=>bug.id
    assert !Bug.exists?(bug.id)
    assert_redirected_to bugs_path
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
end
