ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require File.expand_path(File.dirname(__FILE__) + "/mocks/acts_as_solr.rb")
require 'test_help'

class ActiveSupport::TestCase
  
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually 
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  # From: http://www.bigbold.com/snippets/posts/show/1170
  # Useful for testing Rails ActiveRecord validations. For more information see:
  # http://wiseheartdesign.com/articles/2006/01/16/testing-rails-validations/
  
  def assert_valid(field, *values)
    __model_check__
    values.each do |value|
      o = __setup_model__(field, value)
      if o.valid?
        assert_block { true }
      else
        messages = [o.errors[field]].flatten
        assert_block("unexpected invalid field <#{o.class}##{field}>, value: <#{value.inspect}>, errors: <#{o.errors[field].inspect}>.") { false }
      end
    end
  end

  def assert_invalid(field, message, *values)
    __model_check__
    values.each do |value|
      o = __setup_model__(field, value)
      if o.valid?
        assert_block("field <#{o.class}##{field}> should be invalid for value <#{value.inspect}> with message <#{message.inspect}>") { false }
      else
        messages = [o.errors[field]].flatten
        assert_block("field <#{o.class}##{field}> with value <#{value.inspect}> expected validation error <#{message.inspect}>, but got errors <#{messages.inspect}>") { messages.include?(message) }
      end
    end
  end

  def __model_check__
    raise "@model must be assigned in order to use validation assertions" if @model.nil?

    o = @model.dup
    raise "@model must be valid before calling a validation assertion, instead @model contained the following errors #{o.errors.instance_variable_get('@errors').inspect}" unless o.valid?
  end

  def __setup_model__(field, value)
    o = @model.dup
    attributes = o.instance_variable_get('@attributes')
    o.instance_variable_set('@attributes', attributes.dup)
    o.send("#{field}=", value)
    o
  end

  def do_default_routing_tests(resource)
    assert_routing "/#{resource}/new", :controller=>resource, :action=>"new"
    assert_routing "/#{resource}/1", :controller=>resource,:action=>"show", :id=>"1"
    assert_routing({:path=>"/#{resource}", :method=>'post'}, {:controller=>resource,:action=>"create"})
    assert_routing({:path=>"/#{resource}/1", :method=>'delete'}, {:controller=>resource,:action=>"destroy", :id=>'1'})
    assert_routing({:path=>"/#{resource}/1", :method=>'put'}, {:controller=>resource,:action=>"update", :id=>'1'})
    assert_routing "/#{resource}/1/edit", :controller=>resource,:action=>"edit", :id=>"1"
  end
end


# Turn off Solr during tests
class ActsAsSolr::Post
  def self.execute(request)
    true
  end
end
