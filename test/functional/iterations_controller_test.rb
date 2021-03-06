require File.dirname(__FILE__) + '/../test_helper'

class IterationsControllerTest < ActionController::TestCase
  def setup
    @request.session[:user_id]=1
  end
  def test_routes
    do_default_routing_tests('iterations')
  end
  def test_requires_login_except_show_chart
    @request.session[:user_id]=nil
    get :chart, :id=>iterations(:iter_last).id
    assert_response :success
  end
  def test_show_works_with_no_stories
    Story.destroy_all
    Task.destroy_all
    iterations(:iter_last).stories(&:destroy)
    assert_equal 0, iterations(:iter_last).stories.size 
    @request.session[:user_id]=nil
    get :chart, :id=>iterations(:iter_last).id
    assert_response :success
  end
  def test_show_works_with_future_start
    Story.destroy_all
    Task.destroy_all
    iterations(:iter_last).start_date=100.week.from_now.to_date.to_s(:db)
    iterations(:iter_last).end_date=102.week.from_now.to_date.to_s(:db)
    assert iterations(:iter_last).save!
    iterations(:iter_last).stories(&:destroy)
    iterations(:iter_last).stories.create(:title=>'new story', :description=>'new story', :completed_at =>Date.today, :nodule=>'fubari')
    iter=  Iteration.find(iterations(:iter_last).id)
    assert_equal 1, iter.stories.size
    assert_equal :new, iter.stories.first.current_state
    @request.session[:user_id]=nil
    get :chart, :id=>iterations(:iter_last).id
    assert_response :success
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
    get :show, :id=>iterations(:iter_next).id
    assert assigns(:iteration)
    assert_equal assigns(:iteration), iterations(:iter_next)
    assert_template "show"
    assert_select "a[href=?]", iterations_path
    assert_select "a[href=?]", edit_iteration_path(iterations(:iter_next).id)
    assert_select "a[href=?][onclick*=confirm]", iteration_path(iterations(:iter_next))
  end

  def test_destroy
    iteration= iterations(:iter_current)

    delete :destroy, :id=>iterations(:iter_current).id

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

  def test_new
    get :new
    assert_response :success
    assert_template "form"
    assert assigns(:releases)
    assert assigns(:iteration)
    assert assigns(:iteration).new_record?
    assert_select "form[action=?][method=post]", iterations_path do
      assert_select "input[type=text]"
      assert_select "div[class=date_field]"
      assert_select "input[type=text]"
      assert_select "img[alt=Calendar]"
      assert_select "div[class=date_field]"
      assert_select "input[type=text]"
      assert_select "img[alt=Calendar]"
      assert_select "input[type=submit]"
      assert_select "input[type=button][value=Cancel][onclick*=location]"
    end
  end

  def test_edit
    iter = iterations(:iter_last)
    get :edit,:id=>iter.id
    assert assigns(:iteration)
    assert releases = assigns(:releases)
    assert_equal iter, assigns(:iteration)
    assert_template 'form'
    assert_select "form[action=?]", iteration_path(iter) do
      assert_select "input[type=text][id=iteration_title]"
      assert_select "input[type=text][id*=start_date]"
      assert_select "input[type=text][id*=end_date]"
      assert_select "div[class=multiple_select]" do
        releases.each do |release|
          assert_select "label" do
            assert_select "input[type=checkbox][value=?]", release.id
          end
        end
      end
      assert_select "input[type=submit]"
    end

  end

  def test_show_shows_stories
    get :show, :id=>iterations(:iter_last).id
    iteration = assigns(:iteration)
    assert iteration
    story_list = iteration.stories
    swag_sum = 0
    assert_select "table[id=stories]" do
      story_list.each do |s|
        swag_sum += s.swag.to_f
        assert_select "tr" do
          assert_select "td" do
            assert_select "a[href=?]", story_path(s)
          end
        end
      end
    end

    assert_select "[id=sum]", :text=>/#{swag_sum.to_s}/
  end

  def test_load_chart_route
    assert_routing "/iterations/1/chart", :controller=>"iterations",:action=>"chart", :id=>"1"
    get :chart, :id=>iterations(:iter_last).id
    assert_response :success
  end

  def test_iteration_generate_form
    assert_routing({:path=>'/iterations/new/new_generate', :method=>"get"}, {:controller=>'iterations', :action=>'new_generate'})
    get :new_generate
    assert_response :success
    assert_template 'new_generate'
    assert_select "form[action=?]", generate_iterations_path do
      assert_select "input[type=text][id=start_date]"
      assert_select "input[type=text][id=end_date]"
      assert_select "input[type=text][id=days]"
      assert_select "input[type=submit]"
    end
  end
  def test_iteration_generator
    Iteration.destroy_all
    assert_routing({:path=>'/iterations/generate', :method=>"post"}, {:controller=>'iterations', :action=>'generate'})
    post :generate, :start_date=>Date.today.to_s(:db), :end_date=>(14*3).days.from_now.to_date.to_s(:db), :days=>14
    assert_response :redirect
    assert_redirected_to iterations_path
    assert_equal 3, Iteration.count
    assert_equal ((14*3)-1).days.from_now.to_date, Iteration.find(:last, :order=>'start_date asc').end_date
  end

  def test_update

    iteration = iterations(:iter_next)

    put :update, :id=>iteration.id, :iteration=>{"start_date"=>"2008-05-19", "end_date"=>"2008-06-03", "title"=>"Iteration 1"}

    new_iteration = Iteration.find(iteration.id)

    assert_equal "2008-05-19", new_iteration.start_date.strftime("%Y-%m-%d")
    assert_equal "2008-06-03", new_iteration.end_date.strftime("%Y-%m-%d")
    assert_equal "Iteration 1", new_iteration.title

    assert_redirected_to iterations_path
  end
  
  def test_show_json
      get :show, :id=>iterations(:iter_next).id, :format=>"json"
      assert assigns(:iteration)
      assert_equal assigns(:iteration), iterations(:iter_next)
      assert_response :success
  end
  
  def test_reset_swags
    assert_routing({:path=>"/iterations/1/reset_swags", :method=>'put'}, {:controller=>"iterations", :action=>"reset_swags", :id=>"1"})
    iter = iterations(:iter_current)
    put :reset_swags, :id=>iter.id
    assert_response :redirect
    assert_redirected_to(iteration_path(iter))
    i2 = assigns(:iteration)
    i2.stories.each do |s|
      assert_nil(s.swag) if s.state != 'passed'
    end
  end
  
  def test_promote_stories_and_bugs
    assert_routing({:path=>"/iterations/1/promote", :method=>'put'}, {:controller=>"iterations", :action=>"promote", :id=>"1"})
    iter = iterations(:iter_current)
    passed_stories = iter.stories.select{|s| s.state != 'passed'}
    passed_bugs = iter.bugs.select{|b| b.state != 'passed'}
    put :promote, :id=>iter.id
    assert_response :redirect
    assert_redirected_to(iteration_path(iter))
    iter.reload.stories.each do |s|
      assert_equal('passed', s.state)
    end
    iter.bugs.each do |b|
      assert_equal('passed', b.state)
    end
    passed_stories.each do |ps|
      assert(!iter.stories.include?(ps), "#{ps.title} should have been moved!")
      assert(iter.next.stories.include?(ps), "#{ps.title} should have been moved!")
    end
    passed_bugs.each do |pb|
      assert(!iter.bugs.include?(pb), "#{pb.title} should have been moved!")
      assert(iter.next.bugs.include?(pb), "#{pb.title} should have been moved!")
    end
  end

end
