require File.dirname(__FILE__) + '/../test_helper'

class ReleaseTest < ActiveSupport::TestCase
  def test_iteration_relation
    s = Release.new
    assert s.respond_to?("iterations")
  end
  
  def test_find_current
    assert_equal releases(:currel), Release.current
  end

  def test_find_all_releases
    release_list = Release.find(:all)
    assert_not_nil(release_list)
    assert(!release_list.empty?, "no releases found")
  end

  def test_validation
    @model = Release.new(:title=>"Title")
    assert_invalid(:title, "is too short (minimum is 1 characters)", "")
    assert_invalid(:title, "is too long (maximum is 75 characters)", ('a'*76))
  end
  
  def test_iterations
    r = Release.current
    iters = r.iterations
    assert_equal(2, iters.length)
    assert_equal(iters.first, iterations(:current))
    assert_equal(iters.last, iterations(:next))
  end
  
end
