require File.dirname(__FILE__) + '/../test_helper'

class IterationTest < ActiveSupport::TestCase
  def test_story_relation
    s = Iteration.new
    assert s.respond_to?("stories")
  end
  def test_find_current
    assert_equal iterations(:current), Iteration.current
  end

  def test_velocity
    assert_equal 2.3.to_s, iterations(:current).velocity.to_s
  end
  def test_velocity_w_nil_swag
    assert iterations(:current).stories.create(:title=>'nilswag')
    assert_equal 2.3.to_s, iterations(:current).reload.velocity.to_s
  end

  def test_find_all_iterations
    iteration_list = Iteration.find(:all)
    assert_not_nil(iteration_list)
    assert(!iteration_list.empty?, "no iterations found")
  end

  def test_validation
    @model = Iteration.new(:title=>"Title", :start_date=>"2008-06-07", :end_date=>"2008-06-21")
    assert_valid(:start_date, '2008-06-07')
    assert_valid(:end_date, '2008-06-21')
    assert_invalid(:start_date, "is an invalid date format", 'i am invalid', nil)
    assert_invalid(:end_date, 'is an invalid date format', 'i am invalid', nil)
    assert_invalid(:title, "is too short (minimum is 1 characters)", "")
    assert_invalid(:title, "is too long (maximum is 200 characters)", ('a'*198) + "rgh")
  end
  
  def test_validates_start_end_properly
    i = Iteration.new(:title=>"Title", :start_date=>1.days.from_now.to_s, :end_date=>-2.days.from_now.to_s)
    assert !i.valid?
    assert_equal i.errors.on(:start_date), "must be before the end date"

  end
  def test_total_points
    i = iterations(:current)
    assert 2, i.stories.size
    assert_equal 9.3, iterations(:current).total_points
  end
  def test_open_points
    assert_equal 7, iterations(:current).open_points
  end

  def test_completed_points
    assert_equal 2.3, iterations(:current).completed_points
  end

  def test_iter_days
    assert_equal 12, iterations(:current).total_days
  end
end
