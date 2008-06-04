require File.dirname(__FILE__) + '/../test_helper'

class TaskTest < ActiveSupport::TestCase
  def test_find_all_tasks
    task_list = Task.find(:all)
    assert_not_nil(task_list)
    assert(!task_list.empty?, "no tasks found")
  end

  def test_attributes
    expected_attribs = ["title", "description", "aasm_state"]
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
    assert_equal "can't be blank", t.errors.on(:description)
    assert_equal "can't be blank", t.errors.on(:title)
  end

  def test_title_too_long
    t = Task.new :description=>"New Task Description"
    long_str = (1..201).map{"a"}.to_s
    t.title = long_str
    assert(!t.save)
    assert_equal "is too long (maximum is 200 characters)", t.errors.on(:title)
  end

  def test_story_relation_sorting
    t = Task.new :title=>"New Task Title", :description=>"New Task Description"
    assert(t.save)
    t.stories.create({:title=>"ZTitle"})
    t.stories.create({:title=>"ATitle"})
    assert_equal("ATitle", t.stories.first().title)
    assert_equal("ZTitle", t.stories.last().title)
  end

  def test_state_model
    t = Task.new :title=>"New Task Title", :description=>"New Task Description"
    assert(t.save)
    assert_equal "new", t.aasm_state
    t.start!
    assert_equal "in_progress", t.aasm_state
    t.stop!
    assert_equal "new", t.aasm_state
    t.start!
    t.finish!
    assert_equal "complete", t.aasm_state
    t.reopen!
    assert_equal "in_progress", t.aasm_state
  end

  def test_fanout
    t = Task.create :title=>"New Task Title", :description=>"New Task Description"
    t.start!
    assert_equal  [:finish, :stop],  t.aasm_events_for_current_state

  end

end
