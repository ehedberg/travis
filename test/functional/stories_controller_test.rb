require File.dirname(__FILE__) + '/../test_helper'

class StoriesControllerTest < ActionController::TestCase
  def setup
    @request.session[:user_id]=1
     
  end

  def test_fixtures
    s = stories(:one)
    assert_equal audit_records(:one), s.audit_records.first
  end

  def teardown
    @request.session[:user_id]=nil
  end

  def test_routes
    do_default_routing_tests('stories')
  end
  def test_create_bad
    assert Story.create(:title=>'New Title', :description=>'bleahd', :swag=>3, :nodule=>'blahr')
    post :create, "story"=>{"title"=>"New Title", "description"=>"de", "swag"=>"2"}
    assert_response :success
    assert_template 'form'
    assert assigns(:story)
    assert_equal 'has already been taken', assigns(:story).errors.on(:title)
    assert_equal "can't be blank", assigns(:story).errors.on(:nodule)
    assert_select "#errorExplanation" do 
      assert_select "h2"
      assert_select "ul>li", 2
    end
  end
  
  def test_create
    post :create, "story"=>{"title"=>"New Title", "description"=>"de", "swag"=>"2", :nodule=>'rhubarb', :tag_list => 'foo, bar, baz'}
    assert story = assigns(:story)
    assert_equal Story.find_by_description("de"), assigns(:story)
    assert_response :redirect
    assert_redirected_to story_path(assigns(:story))
    assert_equal(['foo', 'bar', 'baz'], story.reload.tag_list)
  end

  def test_search_view
    assert_routing({:path=>"/stories/search", :method=>'get'}, :controller=>'stories', :action=>'search')
    get :search
    assert_response :success
    assert_template 'search'
    assert assigns(:saved_searches)
    assigns(:saved_searches).each do |x|
      assert_equal x.query_type, 'Story'
    end
    assert_select "ul#savedSearches" do 
        assert_select "li", SavedSearch.for_stories.size  do
          assert_select "a[href=#]"
      end
    end
  end
  def test_do_tag_search
    s = stories(:one)
    s.tag_list.add('abc')
    s.save!

    assert_routing({:path=>"/stories/do_search",:method=>'post'}, :controller=>'stories', :action=>'do_search')
    xhr :post, :do_search, "tagsearch"=>"1", "expr"=>"abc"

    assert_response :success
    assert assigns(:stories)
    ts = assigns(:stories)
    ts.each do |t|
      assert_equal  :new, t.current_state
    end
    assert_equal 1, ts.size
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
    assert_routing({:path=>"/stories/do_search",:method=>'post'}, :controller=>'stories', :action=>'do_search')
    xhr :post, :do_search, :expr=>"state = 'new'"
    assert_response :success
    assert assigns(:stories)
    ts = assigns(:stories)
    ts.each do |t|
      assert_equal  :new, t.current_state
    end
    assert_equal 6, ts.size
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


  def test_create_invalid_title
    post :create, "story"=>{"description"=>"de", "swag"=>"2", :nodule=>'rhubarb'}
    assert_response :success
    assert_template "form"
    assert assigns(:story)
    story = assigns(:story)
    assert_equal story.errors.on(:title), "is too short (minimum is 4 characters)"
    assert_select "div[id=errorExplanation][class=errorExplanation]"
  end

  def test_requires_login
    @request.session[:user_id]=nil
    get :index
    assert_response :redirect
    assert_redirected_to new_session_path
    @request.session[:user_id]=1
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

    assert_select "table[id=stories]" do
      stories.each do |s|
        assert_select "tr" do
          assert_select "td", :text=>"#{s.mnemonic}" do
            assert_select "a[href=?]", story_path(s.id)
          end
          assert_select "td:last-child" do
            assert_select "a[href=?]", story_path(s.id)
            assert_select "a[href=?]", edit_story_path(s.id)
          end
        end
      end
    end

    assert_select "a[href=?]", new_story_path
  end

  def test_update_swag
    xhr :post, :update_swag, "id"=>stories(:one).id, "value"=>"2.0\n            ", "controller"=>"stories", "editorId"=>"swag_1"
    assert_response :success
    assert_equal "2.0", @response.body
  end
  
  def test_update_tags
    xhr :post, :update_tags, "id"=>stories(:one).id, "value"=>"your mom", "controller"=>"stories", "editorId"=>"swag_1"
    assert_response :success
    assert_equal 'your mom', @response.body
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
      assert_select "input[type=text][id=story_nodule]"
      assert_select "input[type=submit]"
      assert_select "input[type=button][value=Cancel][onclick*=location]"
    end
  end

  def test_show
    get :show, :id=>stories(:one).id
    assert assigns(:story)
    assert_equal assigns(:story), stories(:one)
    assert_template "show"
    assert_select "a[href=?]", iteration_path(stories(:one).iteration), :text=>"#{stories(:one).iteration.title}"
    assert_select "a[href=?]", stories_path
    assert_select "a[href=?]", edit_story_path(stories(:one).id)
    assert_select "a[href=?][onclick*=confirm]", story_path(stories(:one))
    assert_select "form[action=?]", tasks_path do
      assert_select "input[type=text][id=task_title]"
      assert_select "textarea[id=task_description]"
      assert_select "input[type=submit]"
    end
    assert_select "a[href=#taskform][id=tasklink]"
  end

  def test_mass_bigtag
    s1 = stories(:one)
    s2 = stories(:two)
    assert_routing({:method=>'post', :path=>'/stories/mass_tag'}, :controller=>'stories', :action=>'mass_tag')
    post :mass_tag, :ids=>[s2.id, s1.id], :tags=>'some dumb tag'
    assert_response :success
    s1.reload
    s2.reload
    assert_equal ["some dumb tag"], s1.tag_list
    assert_equal ["some dumb tag"], s2.tag_list
    
  end
  def test_mass_tag
    s1 = stories(:one)
    s2 = stories(:two)
    s2.tag_list.add("foo")
    s2.save!
    assert_routing({:method=>'post', :path=>'/stories/mass_tag'}, :controller=>'stories', :action=>'mass_tag')
    post :mass_tag, :ids=>[s2.id, s1.id], :tags=>'some, dumb, tag'
    assert_response :success
    s1.reload
    s2.reload
    assert_equal %w(some dumb tag), s1.tag_list
    assert_equal %w(foo some dumb tag), s2.tag_list
    
  end
  def test_show_history_link
    assert_routing "/stories/1/history", {:action=>"history", :controller=>"stories", :id=>"1"}
    get :show, :id=>stories(:one).id
    assert assigns(:story)
    assert_not_nil assigns(:story).audit_records
    assert_equal assigns(:story), stories(:one)
    assert_template "show"
    assert_select "a[href=#]"
  end

  
  def test_update_fires_event
    story = stories(:one)
    story.tasks.clear
    story.save!
    story.tasks=[tasks(:one)]
    story.save!
    story.tasks.first.start!
    story.tasks.first.reload.finish!
    story.reload
    assert_equal :in_qc, story.current_state
    put :update, :id=>story.id, :story=> {:title=>"New title", :description=>"New Description", :swag=>"9999.99", :state=>'fail' }
    new_story = Story.find(story.id)
    assert_equal "New title", new_story.title
    assert_equal "New Description", new_story.description
    assert_equal 9999.99, new_story.swag
    assert_redirected_to story_path(assigns(:story))
    assert_equal :failed, new_story.current_state
  end

  def test_update
    story = stories(:one)
    put :update, :id=>story.id, :story=> {:title=>"New title", :description=>"New Description", :swag=>"9999.99" }
    new_story = Story.find(story.id)
    assert_equal "New title", new_story.title
    assert_equal "New Description", new_story.description
    assert_equal 9999.99, new_story.swag
    assert assigns(:story)
    assert_redirected_to story_path(assigns(:story))
    assert_not_equal :fubar, new_story.current_state
  end

  def test_update_invalid_title

    story = stories(:one)

    put :update, :id=>story.id, :story=> {:title=>"", :description=>"New Description", :swag=>"9999.99" }

    assert_response :success

    assert_template "form"

    new_story = Story.find(story.id)

    s = assigns(:story)

    assert_equal s.errors.on(:title), "is too short (minimum is 4 characters)"

    assert_select "div[id=errorExplanation][class=errorExplanation]"

  end
  def test_update_with_tags
    story = stories(:one)
    assert_equal([], story.tag_list)
    put :update, :id=>story.id, :story=> {:title=>"The title", :description=>"New Description", :swag=>"99.99", :tag_list => 'foo, bar, baz' }
    assert_response :redirect
    assert_redirected_to story_path(story)
    assert_equal(['foo', 'bar', 'baz'], story.reload.tag_list)
  end
  
  def test_update_modify_tags
    story = stories(:one)
    story.tag_list="foo, bar, baz"
    assert_equal(['foo', 'bar', 'baz'], story.tag_list)
    put :update, :id=>story.id, :story=> {:title=>"The title", :description=>"New Description", :swag=>"99.99", :tag_list => 'baz' }
    assert_response :redirect
    assert_redirected_to story_path(story)
    assert_equal(['baz'], story.reload.tag_list)
  end
  def test_update_remove_tags
    story = stories(:one)
    story.tag_list="foo, bar, baz"
    assert_equal(['foo', 'bar', 'baz'], story.tag_list)
    put :update, :id=>story.id, :story=> {:title=>"The title", :description=>"New Description", :swag=>"99.99" }
    assert_response :redirect
    assert_redirected_to story_path(story)
    assert_equal([], story.reload.tag_list)
  end
  def test_edit
    get :edit,:id=>stories(:one).id

    assert assigns(:story)

    story = assigns(:story)

    assert_equal stories(:one).id, story.id
  end

  def test_destroy_story_not_in_iteration
    story = stories(:two)
    delete :destroy, :id=>stories(:two).id
    assert !Story.exists?(story.id)
    assert_redirected_to stories_path
  end

  def test_destroy_story_in_iteration
    story = stories(:one)
    assert_equal(iterations(:iter_last), story.iteration)
    delete :destroy, :id=>stories(:one).id
    assert !Story.exists?(story.id)
    assert_redirected_to iteration_path(iterations(:iter_last))
  end

  def test_edit_view

    get :edit,:id=>stories(:one).id

    assert assigns(:story)

    story = assigns(:story)

    assert_select "form[action=?][method=post]", story_path do
      assert_select "input[name=_method][type=hidden][value=put]"
      assert_select "textarea[id=story_description]", {:text=>story.description}
      assert_select "input[type=text][value=?]", story.swag
      iteration_list = Iteration.find(:all)
      assert_select "select" do
        iteration_list.each do |i|
          if i.id == 1
            assert_select "option[selected][value=?]", i.id, :text=>i.title
          else
            assert_select "option[value=?]", i.id, :text=>i.title
          end
        end
      end
      assert_select "input[type=submit]"
    end
  end
  
  def test_index_search
    desc = rand(1000000000000000000)
    s = Story.generate!(:description => desc)
    s2 = Story.generate!(:description => desc)
    get :index, :q => desc.to_s
    assert_response :success
    assert_template "index"
    assert assigns(:stories)
    assert_equal 2, assigns(:stories).length
    assert_equal s.id, assigns(:stories)[0].id
  end
  
  def test_index_search_paginates_first_page
    desc = rand(1000000000000000000)
    30.times do
      Story.generate!(:description => desc)
    end
    get :index, :q => desc.to_s
    assert_response :success
    assert_template "index"
    assert assigns(:stories)
    assert_equal Story.per_page, assigns(:stories).length
  end
  
  def test_index_search_paginates_subsequent_page
    desc = rand(1000000000000000000)
    
    # if per_page is 20, this will be 30
    num_stories_to_gen = (Story.per_page * 2) - (Story.per_page / 2)
    num_stories_to_gen.times do
      Story.generate!(:description => desc)
    end
    get :index, :q => desc.to_s, :page => 2
    assert_response :success
    assert_template "index"
    assert assigns(:stories)
    assert_equal Story.per_page / 2, assigns(:stories).length
  end
  
end
