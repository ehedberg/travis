require 'test_helper'

class ReleasesControllerTest < ActionController::TestCase
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
    release = releases(:current)

    delete :destroy, :id=>releases(:current).id

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



end
