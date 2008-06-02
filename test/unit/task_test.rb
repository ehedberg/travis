require 'test_helper'

class TaskTest < ActiveSupport::TestCase
  def test_find_all_tasks
    task_list = Task.find(:all)
    assert_not_nil(task_list)
    assert(!task_list.empty?, "no tasks found")
  end

  def test_attributes
    expected_attribs = ["title", "description"]
    expected_attribs.each do |e|
      assert(Task.new.respond_to?(e))
    end
  end

  def test_story_relation
    t = Task.new
    assert_not_nil(t.stories)
  end
end
