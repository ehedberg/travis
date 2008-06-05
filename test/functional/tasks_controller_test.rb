require File.dirname(__FILE__) + '/../test_helper'
$:.reject! { |e| e.include? 'TextMate' }

class TasksControllerTest < ActionController::TestCase

  def setup
    @request.session[:login]='fubar'
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
    assert_recognizes({:controller=>"tasks",:action=>"take", :id=>"1"}, :path=>"/tasks/1/take", :method=>"post")
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

    assert_select "input[type=submit][id=take_button]"
    assert_select "input[type=button][value='Show All'][onclick*=location]"
    assert_select "input[type=button][value='Edit'][onclick*=location]"
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
    post :create, :task=>{"title"=>"spam", "description"=>"spam description"}
    assert_response :redirect
    t = assigns(:task)
    assert_redirected_to task_path(t)
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
    assert_select "form[action=?][method=post]", task_path(t.id) do
      assert_select "input[id=task_title][type=text]"
      assert_select "textarea[id=task_description]"
      assert_select "input[type=submit][class=submit_button]"
    end
  end

  def test_update
    n = Task.count
    put :update, :id=>tasks(:one).id, :task=>{"title"=>"updated title", "description"=>"updated description"}
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

  def test_take
    @request.session[:login] = 'foo'
    put :take, :id=>tasks(:one).id
    t = assigns(:task)
    assert_equal 'foo', t.login
    assert_equal :in_progress, t.aasm_current_state
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

  def test_edit_shows_stories
    get :edit, :id=>tasks(:one).id
    t = assigns(:task)
    assert t
    story_list = Story.find(:all)
    assert_select "form select[multiple=multiple][size=5]" do
      story_list.each do |s|
        assert_select "option[value=?]", s.id, :text=>s.title
      end
    end
  end

  def test_update_saves_stories
    t = Task.create :description=>"update test desc", :title=>"update test title"
    s1 = Story.create :title=>"S1 title", :description=>"S1 desc"
    s2 = Story.create({:title=>"S2 title", :description=>"S2 desc"})
    put :update, :id=>t.id, :task=>{"story_ids"=>[s1.id, s2.id]}
    t = assigns(:task).reload
    assert_equal t.story_ids, [s1.id, s2.id]
  end

end
