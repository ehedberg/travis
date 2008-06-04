require File.dirname(__FILE__) + '/../test_helper'

class IterationsControllerTest < ActionController::TestCase
  def test_routes
    assert_routing "/iterations/new", :controller=>"iterations",:action=>"new"
    assert_routing "/iterations/1", :controller=>"iterations",:action=>"show", :id=>"1"
    assert_recognizes({:controller=>"iterations",:action=>"create"}, :path=>"/iterations", :method=>"post")
    assert_recognizes({:controller=>"iterations",:action=>"destroy", :id=>"1"}, :path=>"/iterations/1", :method=>"delete")
    assert_recognizes({:controller=>"iterations",:action=>"update", :id=>"1"}, :path=>"/iterations/1", :method=>"put")
    assert_routing "/iterations/1/edit", :controller=>"iterations",:action=>"edit", :id=>"1"
  end

  def test_index
    get :index
    assert assigns(:iterations)
    iterations = assigns(:iterations)

    assert !iterations.empty?

    assert iterations.kind_of?(Array)

    assert_select "table[id=iterations]" do
      iterations.each do |s|
        assert_select "tr" do
          assert_select "td" do
            assert_select "a[href=?]", iteration_path(s.id)
          end
          assert_select "td"
          assert_select "td" do
            assert_select "a[href=?]", iteration_path(s.id)
          end
          assert_select "td" do
            assert_select "a[href=?]", edit_iteration_path(s.id)
          end
        end
      end
    end

    assert_select "a[href=?]", new_iteration_path
  end

end
