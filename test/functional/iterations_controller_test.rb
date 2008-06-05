require File.dirname(__FILE__) + '/../test_helper'

class IterationsControllerTest < ActionController::TestCase
  def setup
    @request.session[:login]='fubar'
  end
  def test_routes
    assert_routing "/iterations/new", :controller=>"iterations",:action=>"new"
    assert_routing "/iterations/1", :controller=>"iterations",:action=>"show", :id=>"1"
    assert_recognizes({:controller=>"iterations",:action=>"create"}, :path=>"/iterations", :method=>"post")
    assert_recognizes({:controller=>"iterations",:action=>"destroy", :id=>"1"}, :path=>"/iterations/1", :method=>"delete")
    assert_recognizes({:controller=>"iterations",:action=>"update", :id=>"1"}, :path=>"/iterations/1", :method=>"put")
    assert_routing "/iterations/1/edit", :controller=>"iterations",:action=>"edit", :id=>"1"
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
    assert assigns(:iterations)
    iterations = assigns(:iterations)

    assert !iterations.empty?

    assert iterations.kind_of?(Array)

    assert_select "table[id=iterations]" do
      iterations.each do |s|
        assert_select "tr" do
          assert_select "td" do
            assert_select "a[href=?]", iteration_path(s.id)
          end
          assert_select "td"
          assert_select "td" do
            assert_select "a[href=?]", iteration_path(s.id)
          end
          assert_select "td" do
            assert_select "a[href=?]", edit_iteration_path(s.id)
          end
        end
      end
    end

    assert_select "a[href=?]", new_iteration_path
  end

  def test_show
    get :show, :id=>iterations(:three).id
    assert assigns(:iteration)
    assert_equal assigns(:iteration), iterations(:three)
    assert_template "show"
    assert_select "a[href=?]", iterations_path
    assert_select "a[href=?]", edit_iteration_path(iterations(:three).id)
    assert_select "a[href=?][onclick*=confirm]", iteration_path(iterations(:three))
  end

  def test_destroy
    iteration= iterations(:two)

    delete :destroy, :id=>iterations(:two).id

    assert !Iteration.exists?(iteration.id)

    assert_redirected_to iterations_path
  end

  def test_create
    post :create, "iteration"=>{"title"=>"New Iteration", "start_date"=>"2008-06-07", "end_date"=>"2008-06-21"}

    assert assigns(:iteration)

    iteration = assigns(:iteration)

    assert_equal Iteration.find_by_title("New Iteration"), assigns(:iteration)

    assert_response :redirect

    assert_redirected_to iterations_path
  end

  def test_create_invalid_title_not_found

    post :create, "iteration"=>{"start_date"=>"2008-06-07", "end_date"=>"2008-06-21"}

    assert_response :success

    assert_template "form"

    assert assigns(:iteration)

    story = assigns(:iteration)

    assert_equal story.errors.on(:title), "is too short (minimum is 1 characters)"

    assert_select "div[id=errorExplanation][class=errorExplanation]"
  end

#  def test_create_invalid_start_date

#    post :create, "iteration"=>{"title"=>"New Iteration", "start_date"=>"/6/7", "end_date"=>"2008-06-21"}

#   assert_response :success

#    assert_template "form"

#    assert assigns(:iteration)

#    story = assigns(:iteration)

#    assert_equal story.errors.on(:start_date), "is too short (minimum is 1 characters)"

#    assert_select "div[id=errorExplanation][class=errorExplanation]"
#  end

  def test_new
    get :new

    assert_response :success

    assert_template "form"

    assert assigns(:iteration)

    assert assigns(:iteration).new_record?

    assert_select "form[action=?][method=post]", iterations_path do
      assert_select "input[type=text]"
      assert_select "input[type=text]"
      assert_select "input[type=text]"
      assert_select "input[type=submit]"
      assert_select "input[type=button][value=Cancel][onclick*=location]"
    end
  end

  def test_edit
    get :edit,:id=>iterations(:one).id

    assert assigns(:iteration)

    iteration = assigns(:iteration)

    assert_equal iterations(:one).id, iteration.id
  end

  def test_show_shows_stories
    get :show, :id=>iterations(:one).id
    iteration = assigns(:iteration)
    assert iteration
    story_list = iteration.stories
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

end
