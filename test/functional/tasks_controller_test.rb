require File.dirname(__FILE__) + '/../test_helper'
$:.reject! { |e| e.include? 'TextMate' }

class TasksControllerTest < ActionController::TestCase

  def setup
    @request.session[:login]='fubar'
  end

  def teardown
    @request.session[:login]=nil
  end

  def test_create_ajax
    xhr :post,  :create, "task"=>{"title"=>"New Title", "description"=>"de"}, :story_id=>stories(:one).id
    assert assigns(:task)
    task = assigns(:task)
    assert_equal Task.find_by_description("de"), assigns(:task)
    assert_select_rjs :insert, :bottom,  'tasks'
  end

  def test_bad_ajax_create
    xhr :post,  :create, "task"=>{"title"=>"", "description"=>""}, :story_id=>stories(:one).id
    assert assigns(:task)
    task = assigns(:task)
    assert_nil Task.find_by_description("de"), assigns(:task)
    assert_select_rjs :replace, 'replaceable'
  end

  def test_bad_Create
    post  :create, "task"=>{"title"=>"", "description"=>""}
    assert_response :success
    assert_template 'form'
    assert assigns(:task)
    assert assigns(:task).new_record?
    assert !assigns(:task).valid?
    task = assigns(:task)
    assert_equal "can't be blank", assigns(:task).errors.on(:title)
    assert_equal "can't be blank", assigns(:task).errors.on(:description)
  end

  def test_search_view
    assert_routing({:path=>"/tasks/search", :method=>'get'}, :controller=>'tasks', :action=>'search')
    get :search
    assert assigns(:saved_searches)
    assert_response :success
    assert_template 'search'
    assert_select "form[action=?]", do_search_tasks_path do
      assert_select "input[type=text][name=expr]"
      assert_select "input[type=submit]"
    end
    assert_select "ul#savedSearches" do 
      assert_select "li", SavedSearch.for_tasks.size  do
        assert_select "a[href=#]"
      end
    end
  end

  def test_do_search
    assert_routing({:path=>"/tasks/do_search",:method=>'post'}, :controller=>'tasks', :action=>'do_search')
    xhr :post, :do_search, :expr=>"state = 'new'"
    assert_response :success
    assert_template 'tasks/_task'
    assert assigns(:tasks)
    ts = assigns(:tasks)
    assert_equal 1, ts.size
    assert_equal ts.first, tasks(:one)
    assert_select_rjs  'results'
    assert_select_rjs :replace_html, "saveform" do
      assert_select "form[action=?]", saved_searches_path do
        assert_select 'input[type=hidden][id=saved_search_query]'
        assert_select 'input[type=hidden][id=saved_search_query_type][value=Task]'
        assert_select 'input[type=text][id=saved_search_name]'
        assert_select "input[type=submit]"
      end
    end
  end

  def test_shows_state_form
    get :show, :id=>tasks(:one).id
    assert_response :success
    assert_template 'show'
    assert assigns(:task)
    assert_select "form[action=?]", task_path(assigns(:task)) do
      assert_select "input[type=submit]"
      assert_select "select" do
        assert_select "option", assigns(:task).available_events.size
      end
    end

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

  def test_routes
    do_default_routing_tests('tasks')
  end

  def test_index
    get :index
    assert assigns(:tasks)
    tasks = assigns(:tasks)
    assert !tasks.empty?
    assert tasks.kind_of?(Array)
    assert_template "index"
    assert_select "table[id=tasks]" do
      tasks.each do |s|
        assert_select "tr" do
          assert_select "td" do
            assert_select "a[href=?]", task_path(s.id)
          end
          assert_select "td" do
            assert_select "a[href=?]", task_path(s.id)
          end
          assert_select "td" do
            assert_select "a[href=?]", edit_task_path(s.id)
          end
        end
      end
    end
    assert_select "a[href=?]", new_task_path 
  end

  def test_show
    get :show, :id=>tasks(:one).id
    assert assigns(:task)
    assert_equal assigns(:task), tasks(:one)
    assert_template "show"

    assert_select "a[href=?]", tasks_path
    assert_select "a[href=?]", edit_task_path(tasks(:one))
    assert_select "a[href=?]", task_path(tasks(:one))
  end

  def test_new
    get :new
    assert assigns(:task)
    assert assigns(:task).new_record?
    assert_template "form"
    assert_select "form[action=?][method=post]", tasks_path do
      assert_select "input[id=task_title][type=text]"
      assert_select "textarea[id=task_description]"
      assert_select "input[type=submit]"
    end
  end

  def test_create
    n = Task.count
    post :create, :task=>{"title"=>"spam", "description"=>"spam description", "state"=>""}
    assert_response :redirect
    t = assigns(:task)
    assert_redirected_to tasks_path
    assert_equal t.title, "spam"
    assert_equal t.description, "spam description"
    assert_equal n+1, Task.count
    assert_not_nil Task.find_by_title("spam")
  end

  def test_edit
    get :edit, :id=>tasks(:one).id
    t = assigns(:task)
    assert t
    assert_equal t, tasks(:one)
    assert_template "form"
    story_list = Story.find(:all)
    assert_select "form[action=?][method=post]", task_path(t.id) do
      assert_select "input[id=task_title][type=text]"
      assert_select "textarea[id=task_description]"
      assert_select "select" do
        t.available_events.each do |st|
          assert_select "option[value=?]", st
        end
      end
      assert_select "select[multiple=multiple][size=5]" do
        story_list.each do |s|
          assert_select "option[value=?]", s.id, :text=>s.title
        end
      end
      assert_select "input[type=submit][class=submit_button]"
    end
  end

  def test_update
    n = Task.count
    put :update, :id=>tasks(:one).id, :task=>{"title"=>"updated title", "description"=>"updated description", "state"=>""}
    assert_response :redirect
    t = assigns(:task)
    assert_redirected_to task_path(t)
    assert_equal t.title, "updated title"
    assert_equal t.description, "updated description"
    assert_equal n, Task.count
    assert_not_nil Task.find_by_title("updated title")
  end

  def test_delete
    assert_difference 'Task.count', -1 do
      delete :destroy, :id=>tasks(:one).id
      assert_response :redirect
      assert_redirected_to tasks_path
    end
  end

  def test_list_shows_stories
    get :index
    assert_template "index"
    task_list = assigns(:tasks)
    assert_select "table[id=tasks]" do
      task_list.each do |t|
        assert_select "tr" do
          assert_select "td" do
            assert_select "a[href=?]", story_path(t.stories.first.id)
          end
        end
      end
    end
  end

  def test_show_shows_stories
    get :show, :id=>tasks(:one).id
    t = assigns(:task)
    assert t
    story_list = t.stories
    assert_select "table[id=stories]" do
      story_list.each do |s|
        assert_select "tr" do
          assert_select "td" do
            assert_select "a[href=?]", story_path(s)
          end
        end
      end
    end
  end

  def test_update_saves_stories
    t = Task.create :description=>"update test desc", :title=>"update test title", :state=>""
    s1 = Story.create :title=>"S1 title", :description=>"S1 desc"
    s2 = Story.create({:title=>"S2 title", :description=>"S2 desc"})
    put :update, :id=>t.id, :task=>{"story_ids"=>[s1.id, s2.id], "state"=>""}
    t = assigns(:task).reload
    assert_equal t.story_ids, [s1.id, s2.id]
  end

  def test_actions
    t = Task.new :title=>"My Title", :description=>"My Description"
    assert(t.save)
    assert_equal "new", t.state
    assert_equal nil, t.login

    put :update, :id=>t.id, :task=>{"state"=>"start"}
    t = assigns(:task)
    assert_equal "in_progress", t.state
    assert_equal session[:login], t.login

    put :update, :id=>t.id, :task=>{"state"=>"stop"}
    t = assigns(:task)
    assert_equal "new", t.state
    assert_equal nil, t.login

    put :update, :id=>t.id, :task=>{"state"=>"start"}
    put :update, :id=>t.id, :task=>{"state"=>"finish"}
    t = assigns(:task)
    assert_equal "complete", t.state
    assert_equal session[:login], t.login
  end

  def test_relates_properly
    xhr :post, :create,  "task"=>{"title"=>"thisone task", "description"=>"this should be on story 4"}, "story_id"=>stories(:one).id
    assert_response :success
    nt = Task.find_by_title('thisone task')
    assert_not_nil nt
    assert Story.find(stories(:one).id).tasks.include?(nt)
  end

  def test_relates_properly_for_bad_task_data
    c = Story.find(stories(:one).id).tasks.size
    xhr :post, :create,  "task"=>{"title"=>"", "description"=>""}, "story_id"=>stories(:one).id
    assert_response :success
    assert assigns(:task).new_record?
    assert_equal c, Story.find(stories(:one).id).tasks.size
  end
end
