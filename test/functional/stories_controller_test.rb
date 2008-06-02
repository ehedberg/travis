require 'test_helper'

class StoriesControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  def test_routes
    assert_routing "/stories", :controller=>"stories",:action=>"index"

    assert_routing "/stories/new", :controller=>"stories",:action=>"new"

    assert_routing "/stories/1", :controller=>"stories",:action=>"show", :id=>"1"

    assert_recognizes({:controller=>"stories",:action=>"create"}, :path=>"/stories", :method=>"post")

    assert_recognizes({:controller=>"stories",:action=>"destroy", :id=>"1"}, :path=>"/stories/1", :method=>"delete")

    assert_recognizes({:controller=>"stories",:action=>"update", :id=>"1"}, :path=>"/stories/1", :method=>"put")

    assert_routing "/stories/1/edit", :controller=>"stories",:action=>"edit", :id=>"1"
  end
end
