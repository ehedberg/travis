require 'spec/spec_helper'
# require File.join(File.dirname(__FILE__), %w[.. spec_helper])

describe Ziya::Helpers::BaseHelper do    
  
  it "should generate the correct yaml class name" do
    component( "fred" ).should == "fred: !ruby/object:Ziya::Components::Fred\n"
  end
  
  it "should generate the correct yaml clqss name for alias" do
    comp( "fred" ).should == "fred: !ruby/object:Ziya::Components::Fred\n"
  end

  it "should generate the correct yaml drawing class name" do
    drawing( "fred" ).should == "!ruby/object:Ziya::Components::Fred\n"
  end

  it "should generate the correct yaml chart class name" do
    chart( "fred" ).should == "--- !ruby/object:Ziya::Charts::Fred\n"
  end
  
end
