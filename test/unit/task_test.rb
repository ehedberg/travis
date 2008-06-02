require File.dirname(__FILE__) + '/../test_helper'

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
    t = Task.new :title=>"New Task Title", :description=>"New Task Description"
    assert_not_nil(t.stories)
    assert(t.save)
    t.stories.create({:title=>"Story Title"})
    assert_equal(Story.find_by_title("Story Title"), t.stories.first())
  end

  def test_valid_atttributes
    t = Task.new 
    assert(!t.save)
    assert_equal t.errors.on(:description), "can't be blank"
    assert_equal t.errors.on(:title), "can't be blank"
  end
end
