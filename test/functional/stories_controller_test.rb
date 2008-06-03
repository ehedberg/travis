require File.dirname(__FILE__) + '/../test_helper'

class StoriesControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  def test_routes
    assert_routing "/", :controller=>"stories",:action=>"index"

    assert_routing "/stories/new", :controller=>"stories",:action=>"new"

    assert_routing "/stories/1", :controller=>"stories",:action=>"show", :id=>"1"

    assert_recognizes({:controller=>"stories",:action=>"create"}, :path=>"/stories", :method=>"post")

    assert_recognizes({:controller=>"stories",:action=>"destroy", :id=>"1"}, :path=>"/stories/1", :method=>"delete")

    assert_recognizes({:controller=>"stories",:action=>"update", :id=>"1"}, :path=>"/stories/1", :method=>"put")

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

  def test_index
    get :index
    assert assigns(:stories)
    stories = assigns(:stories)

    assert !stories.empty?

    assert stories.kind_of?(Array)

    assert_template "index"

    assert_select "table[id=stories]" do
      stories.each do |s|
        assert_select "tr" do
          assert_select "td" do
            assert_select "a[href=?]", edit_story_path(s.id)
          end
          assert_select "td"
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
    end
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

  def test_edit
    get :edit,:id=>stories(:one).id
    
    assert assigns(:story)

    story = assigns(:story)

    assert_equal stories(:one).id, story.id
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
