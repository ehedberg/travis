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

    #assert_invalid(:start_date, 'Start date is required', nil)

    #assert_invalid(:start_date, 'not a date', '2008/6/7', 'i am invalid')


    #assert_invalid(:end_date, 'not a date', 'i am invalid', '2008/6/7')

    #assert_invalid(:end_date, 'End date is required', nil)

    #assert_invalid(:title, "is too short (minimum is 1 characters)", "")

    #assert_invalid(:title, "is too long (maximum is 20 characters)", ('a'*18) + "rgh")
  end
end
