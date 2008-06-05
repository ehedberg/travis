require File.dirname(__FILE__) + '/../test_helper'

class StoriesControllerTest < ActionController::TestCase
  def setup
    @request.session[:login]='fubar'
  end
  def test_routes
    assert_routing "/", :controller=>"stories",:action=>"index"
    assert_routing "/stories/new", :controller=>"stories",:action=>"new"
    assert_routing "/stories/1", :controller=>"stories",:action=>"show", :id=>"1"
    assert_routing({:path=>'/stories', :method=>'post'}, {:controller=>"stories",:action=>"create"})
    assert_routing({:path=>'/stories/1', :method=>'delete'}, {:controller=>"stories",:action=>"destroy", :id=>'1'})
    assert_routing({:path=>'/stories/1', :method=>'put'}, {:controller=>"stories",:action=>"update", :id=>'1'})
    assert_routing "/stories/1/edit", :controller=>"stories",:action=>"edit", :id=>"1"
  end

  def test_create
    post :create, "story"=>{"title"=>"New Title", "description"=>"de", "swag"=>"2"}

    assert assigns(:story)

    story = assigns(:story)

    assert_equal Story.find_by_description("de"), assigns(:story)

    assert_response :redirect

    assert_redirected_to stories_path
  end

  def test_create_invalid_title

    post :create, "story"=>{"description"=>"de", "swag"=>"2"}

    assert_response :success

    assert_template "form"

    assert assigns(:story)

    story = assigns(:story)

    assert_equal story.errors.on(:title), "is too short (minimum is 1 characters)"

    assert_select "div[id=errorExplanation][class=errorExplanation]"
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

  def test_index
    get :index
    assert assigns(:stories)
    stories = assigns(:stories)

    assert !stories.empty?

    assert stories.kind_of?(Array)

    assert_template "index"
    assert_select "div[id=sum]", :text=>/7.7/

    assert_select "table[id=stories]" do
      stories.each do |s|
        assert_select "tr" do
          assert_select "td" do
            assert_select "a[href=?]", story_path(s.id)
          end
          assert_select "td"
          assert_select "td" do
            assert_select "a[href=?]", story_path(s.id)
          end
          assert_select "td" do
            assert_select "a[href=?]", edit_story_path(s.id)
          end
        end
      end
    end

    assert_select "a[href=?]", new_story_path
  end

  def test_new
    get :new

    assert_response :success

    assert_template "form"

    assert assigns(:story)

    assert assigns(:story).new_record?

    assert_select "form[action=?][method=post]", stories_path do
      assert_select "textarea[id=story_description]"
      assert_select "input[type=text]"
      assert_select "input[type=submit]"
      assert_select "input[type=button][value=Cancel][onclick*=location]"
    end
  end

  def test_show
    get :show, :id=>stories(:one).id
    assert assigns(:story)
    assert_equal assigns(:story), stories(:one)
    assert_template "show"
    assert_select "a[href=?]", stories_path
    assert_select "a[href=?]", edit_story_path(stories(:one).id)
    assert_select "a[href=?][onclick*=confirm]", story_path(stories(:one))
  end

  def test_update

    story = stories(:one)

    put :update, :id=>story.id, :story=> {:title=>"New title", :description=>"New Description", :swag=>"9999.99" }

    new_story = Story.find(story.id)

    assert_equal "New title", new_story.title
    assert_equal "New Description", new_story.description
    assert_equal 9999.99, new_story.swag

    assert_redirected_to stories_path
  end

  def test_update_invalid_title

    story = stories(:one)

    put :update, :id=>story.id, :story=> {:title=>"", :description=>"New Description", :swag=>"9999.99" }

    assert_response :success

    assert_template "form"

    new_story = Story.find(story.id)

    s = assigns(:story)

    assert_equal s.errors.on(:title), "is too short (minimum is 1 characters)"

    assert_select "div[id=errorExplanation][class=errorExplanation]"

  end

  def test_edit
    get :edit,:id=>stories(:one).id

    assert assigns(:story)

    story = assigns(:story)

    assert_equal stories(:one).id, story.id
  end

  def test_destroy
    story = stories(:one)

    delete :destroy, :id=>stories(:one).id

    assert !Story.exists?(story.id)

    assert_redirected_to stories_path
  end

  def test_edit_view

    get :edit,:id=>stories(:one).id

    assert assigns(:story)

    story = assigns(:story)

    assert_select "form[action=?][method=post]", story_path do
      assert_select "input[name=_method][type=hidden][value=put]"
      assert_select "textarea[id=story_description]", {:text=>story.description}
      assert_select "input[type=text][value=?]", story.swag
      assert_select "input[type=submit]"
    end
  end
end
