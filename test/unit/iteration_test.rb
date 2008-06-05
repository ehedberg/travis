require File.dirname(__FILE__) + '/../test_helper'

class IterationTest < ActiveSupport::TestCase
  def test_story_relation
    s = Iteration.new

    assert s.respond_to?("stories")
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
end
