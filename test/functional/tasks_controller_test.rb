require 'test_helper'

class TasksControllerTest < ActionController::TestCase
  def test_routes
    assert_routing "/tasks", :controller=>"tasks",:action=>"index"

    assert_routing "/tasks/new", :controller=>"tasks",:action=>"new"

    assert_routing "/tasks/1", :controller=>"tasks",:action=>"show", :id=>"1"

    assert_recognizes({:controller=>"tasks",:action=>"create"}, :path=>"/tasks", :method=>"post")

    assert_recognizes({:controller=>"tasks",:action=>"destroy", :id=>"1"}, :path=>"/tasks/1", :method=>"delete")

    assert_recognizes({:controller=>"tasks",:action=>"update", :id=>"1"}, :path=>"/tasks/1", :method=>"put")

    assert_routing "/tasks/1/edit", :controller=>"tasks",:action=>"edit", :id=>"1"
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
        end
      end
    end
  end

  def test_show
    get :show, :id=>tasks(:one).id
    assert assigns(:task)
    assert_equal assigns(:task), tasks(:one)
    assert_template "show"
  end

  def test_new
    get :new
    assert assigns(:task)
    assert assigns(:task).new_record?
    assert_template "new"
    assert_select "form[action=?][method=post]", tasks_path do
      assert_select "input[id=task_title][type=text]"
      assert_select "textarea[id=task_description]"
      assert_select "input[type=submit]"
    end
  end
end
