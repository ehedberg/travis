require 'spec/spec_helper'
# require File.join(File.dirname(__FILE__), %w[.. spec_helper])

describe Ziya::Components::SeriesSwitch do
  before( :each ) do
    @comp = Ziya::Components::SeriesSwitch.new
  end
    
  it "should define the correct attribute methods" do
    lambda{ Ziya::Components::SeriesSwitch.attributes[@comp.class.name].each {
     |m| @comp.send( m ) } }.should_not raise_error
  end
    
  it "should flatten component correctly" do
    xml          = Builder::XmlMarkup.new
    @comp.switch = false
    @comp.flatten( xml ).should == "<series_switch>false</series_switch>"
  end
end
