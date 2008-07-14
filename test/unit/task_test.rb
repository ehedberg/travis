require File.dirname(__FILE__) + '/../test_helper'

class TaskTest < ActiveSupport::TestCase

  def test_optimistic_locks
    t = Task.new({:title=>'fubar', :description=>'baz'})
    assert t.save
    t2 = Task.find(t.id)

    t.title='bar'
    assert t.save
    t2.title='meh'
    begin
      t2.save
      fail "shouldn't work"
    rescue ActiveRecord::StaleObjectError=>x
    end
  end
  def test_find_all_tasks
    task_list = Task.find(:all)
    assert_not_nil(task_list)
    assert(!task_list.empty?, "no tasks found")
  end

  def test_attributes
    expected_attribs = %w(title description state login)
    expected_attribs.each do |e|
      assert(Task.new.respond_to?(e), "undefined attr '#{e}'")
    end
  end

  def test_canwrite_to_assoc
    s = Task.find(:first).stories.first
    s.title='fooooo'
    assert s.save!

  end

  def test_story_relation
    t = Task.new :title=>"New Task Title", :description=>"New Task Description"
    assert_not_nil(t.stories)
    assert(t.save)
    t.stories.create(:title=>"Story Title", :nodule=>'fubario')
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
    t.stories.create(:title=>"ZTitle",:nodule=>'fubario')
    t.stories.create(:title=>"ATitle", :nodule=>'fubario')
    assert_equal("ATitle", t.stories.first().title)
    assert_equal("ZTitle", t.stories.last().title)
  end

  def test_state_model
    Session.current_login="xxx"
    t = Task.new :title=>"New Task Title", :description=>"New Task Description"
    assert(t.save)
    assert_equal "new", t.state
    assert_nil t.login
    t.start!
    assert_equal "in_progress", t.state
    assert_equal "xxx", t.login
    t.stop!
    assert_equal "new", t.state
    assert_nil t.login
    t.start!
    t.finish!
    assert_equal "complete", t.state
    assert_equal "xxx", t.login
    t.reopen!
    assert_equal "in_progress", t.state
    assert_equal "xxx", t.login
  end

  def test_fanout
    t = Task.create :title=>"New Task Title", :description=>"New Task Description"
    t.start!
    assert(t.available_events.include?(:finish))
    assert(t.available_events.include?(:stop))
    assert_equal(2, t.available_events.size)
  end

  def test_state_is_protected
    t = Task.create :title=>"New Task Title", :description=>"New Task Description", :state=>"invalid"
    assert(t.save)
    assert_equal "new", t.state
  end

end
