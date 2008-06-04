require File.dirname(__FILE__) + '/../test_helper'

class StoryTest < ActiveSupport::TestCase
  def test_find_all_stories
    story_list = Story.find(:all)
    assert_not_nil(story_list)
    assert(!story_list.empty?, "no stories found")
  end

  def test_task_relation
    s = Story.new
    assert_not_nil(s.tasks)
  end

  def test_iteration_relation
    s = Story.new

    assert s.respond_to?("iteration")
  end

  def test_validation
    @model = Story.new(:title=>"Title", :description=>"The description", :swag=>23)

    assert_valid(:swag, nil, 1, 1.1)

    assert_invalid(:swag, "is not a number", "hey there")

    assert_invalid(:swag, "must be greater than or equal to 0", -1)

    assert_invalid(:swag, "must be less than 10000", 10000)

    assert_valid(:description, nil)

    assert_invalid(:description, "is too long (maximum is 200 characters)", ('a'*198) + "rgh")

    assert_invalid(:title, "is too short (minimum is 1 characters)", "")
  end
end
