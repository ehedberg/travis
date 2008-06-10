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
  def test_has_completed_at
    s= Story.new
    assert(s.respond_to? :completed_at)
  end

  def test_has_state
    s= Story.new
    assert(s.respond_to? :state)
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

    assert_invalid(:title, "is too long (maximum is 200 characters)", ('a'*198) + "rgh")
  end

  def test_state_model
    t = Task.new :title=>"New Task Title", :description=>"New Task Description"

    assert(t.save)

    assert_equal "new", t.state

    s = Story.new(:title=>"Title", :description=>"The description", :swag=>23)

    s.tasks<<t

    assert(s.save)

    assert_equal("new", s.state)

    t.start!

    assert_equal "in_progress", t.stories.first.state

    s.reload

    assert_equal "in_progress", t.state

    assert_equal "in_progress", s.state
    
    t2 = Task.new :title=>"Another Title", :description=>"Another Task Description"

    s.tasks<<t2
     
    t.finish!
    
    s.reload
        
    assert_equal "complete", t.state

    assert_equal "in_progress", s.state 
    
    t2.start!
    
    s.reload

    assert_equal "in_progress", t2.state

    assert_equal "in_progress", s.state

    t2.finish!
    
    s.reload

    assert_equal "complete", t2.state
                  
    assert_equal "ready_for_qa", s.state 
  end

  def test_state_is_protected
    s = Story.create(:title=>"Title", :description=>"The description", :swag=>23, :state=>"invalid")

    assert_equal "new", s.state
  end

end
