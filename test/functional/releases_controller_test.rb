require File.dirname(__FILE__)+'/../test_helper'

class ReleasesControllerTest < ActionController::TestCase
  def setup
    @request.session[:login]='fubar'
  end

  def teardown
    @request.session[:login]=nil
  end

  def test_routes
    do_default_routing_tests('releases')
  end
  
  def test_create
    post :create, "release"=>{"title"=>"New Release"}

    assert assigns(:release)

    release = assigns(:release)

    assert_equal Release.find_by_title("New Release"), assigns(:release)

    assert_response :redirect

    assert_redirected_to releases_path
  end

  def test_destroy
    release = releases(:currel)

    delete :destroy, :id=>release.id

    assert !Release.exists?(release.id)

    assert_redirected_to releases_path
  end
 
  def test_show
    get :show, :id=>releases(:next).id
    assert assigns(:release)
    assert_equal assigns(:release), releases(:next)
    assert_template "show"
    assert_select "a[href=?]", releases_path
    assert_select "a[href=?]", edit_release_path(releases(:next).id)
    assert_select "a[href=?][onclick*=confirm]", release_path(releases(:next))
  end

  def test_index
    get :index
    assert assigns(:releases)
    releases = assigns(:releases)
    assert !releases.empty?
    assert releases.kind_of?(Array)

    assert_select "table[id=releases]" do
      releases.each do |s|
        assert_select "tr" do
          assert_select "td" do
            assert_select "a[href=?]", release_path(s.id)
          end
          assert_select "td"
          assert_select "td" do
            assert_select "a[href=?]", release_path(s.id)
          end
          assert_select "td" do
            assert_select "a[href=?]", edit_release_path(s.id)
          end
        end
      end
    end

    assert_select "a[href=?]", new_release_path
  end

  def test_plan
    assert_routing '/releases/1/planner', :controller=>'releases', :action=>'planner', :id=>'1'
    r = releases(:currel)
    get :planner, :id=>r.id
    assert_response :success
    assert_template 'planner'
    assert assigns(:releases)
    assert assigns(:iterations)
    r = assigns(:releases)
    is = assigns(:iterations)
    r.each do |rel|
      assert_select "div[id=?]", "drop_release_#{rel.id}"
    end
    is.each do |iter|
      assert_select "div[id=?]", "drag_iteration_#{iter.id}"
    end
  end
  
  def test_new
    get :new
    assert_response :success
    assert_template "form"
    assert assigns(:release)
    assert assigns(:release).new_record?
    assert_select "form[action=?][method=post]", releases_path do
      assert_select "input[type=text]"
      assert_select "input[type=submit]"
      assert_select "input[type=button][value=Cancel][onclick*=location]"
    end
  end
  
  def test_edit
    get :edit,:id=>releases(:last).id

    assert assigns(:release)

    release = assigns(:release)

    assert_equal releases(:last).id, release.id
  end

  def test_update

    release = releases(:next)

    put :update, :id=>release.id, :release=>{"title"=>"Release New"}

    new_release = Release.find(release.id)

    assert_equal "Release New", new_release.title

    assert_redirected_to releases_path
  end

  def test_requires_login
    @request.session[:login]=nil
    get :index
    assert_response :redirect
    assert_redirected_to new_session_path
    @request.session[:login]='foo'
    get :index
    assert_response :success
    assert_template 'index'
  end



end
