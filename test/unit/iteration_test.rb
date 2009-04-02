require File.dirname(__FILE__) + '/../test_helper'

class IterationTest < ActiveSupport::TestCase
  def test_fixtures
    Iteration.find(:all).each {|x| assert x.valid?}
  end
  def test_story_relation
    s = Iteration.new
    assert s.respond_to?("stories")
  end

  def test_has_many_releases
    t = iterations(:iter_next)
    t.releases<<Release.new(:title=>'balaskddfj')
    assert t.save
    assert_equal 2, t.releases.size
  end
  def test_find_current
    assert_equal iterations(:iter_current), Iteration.current
  end

  def test_velocity
    assert_equal 2.3.to_s, iterations(:iter_current).velocity.to_s
  end
  def test_story_count
    assert_equal 3, iterations(:iter_current).story_count
  end
  def test_completed_story_count
    assert_equal 1.to_s, iterations(:iter_current).completed_story_count.to_s
  end
  def test_velocity_w_nil_swag
    assert iterations(:iter_current).stories.create(:title=>'nilswag')
    assert_equal 2.3.to_s, iterations(:iter_current).reload.velocity.to_s
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
    i = iterations(:iter_current)
    assert 2, i.stories.size
    assert_equal 16.3, iterations(:iter_current).total_points
  end
  def test_open_points
    assert_equal 14, iterations(:iter_current).open_points
  end

  def test_completed_points
    assert_equal 2.3.to_s, iterations(:iter_current).completed_points.to_s
  end

  def test_iter_days
    assert_equal 12, iterations(:iter_current).total_days
  end
  
  def test_previous_iter
    foo = iterations(:iter_current)
    assert_equal iterations(:iter_last), foo.previous
  end  
  
  def test_previous_iter_has_no_previous
      foo = iterations(:iter_last)
      assert_nil foo.previous
  end
  
  def test_unswagged_count
    assert_equal(1, iterations(:iter_next).stories.unswagged.count)
    assert_equal(0, iterations(:iter_current).stories.unswagged.count)
    assert_equal(0, iterations(:iter_empty).stories.unswagged.count)
  end
end
