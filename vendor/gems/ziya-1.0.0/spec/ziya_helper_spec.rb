require 'spec/spec_helper'
# require File.join(File.dirname(__FILE__), %w[spec_helper])

describe Ziya::Helper do  
  
  describe "ziya_chart" do
    before( :each ) do
      @url = "/fred/blee/duh"
    end
    
    it "should generate the correct html with the default options" do
      ziya_chart( @url, :cache => true ).should == "<object classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\" codebase=\"http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,0,0\" data=\"/charts/charts.swf?library_path=/charts/charts_library&amp;xml_source=%2Ffred%2Fblee%2Fduh&amp;stage_width=400&amp;stage_height=300\" height=\"300\" id=\"ziya_chart\" stage_height=\"300\" stage_width=\"400\" style=\"\" width=\"400\"><param name=\"movie\" value=\"/charts/charts.swf?library_path=/charts/charts_library&amp;xml_source=%2Ffred%2Fblee%2Fduh&amp;stage_width=400&amp;stage_height=300\"><param name=\"quality\" value=\"high\"><embed bgcolor=\"#FFFFFF\" height=\"300\" name=\"ziya_chart\" pluginspage=\"http://www.macromedia.com/go/getflashplayer\" quality=\"high\" src=\"/charts/charts.swf?library_path=/charts/charts_library&amp;xml_source=%2Ffred%2Fblee%2Fduh&amp;stage_width=400&amp;stage_height=300\" swLiveConnect=\"true\" type=\"application/x-shockwave-flash\" width=\"400\" wmode=\"transparent\"></embed><param name=\"bgcolor\" value=\"#FFFFFF\"><param name=\"wmode\" value=\"transparent\"></object>"
    end
    
    it "should set the wmode to opaque if bg_color is set" do
      html = ziya_chart( @url, :bgcolor => "ffffff" )
      html.index (/name=\"wmode\" value=\"opaque\"/).should_not be_nil
      html.index (/wmode=\"opaque\"/).should_not be_nil      
    end
    
    it "should handle the size has widthxheight" do
      html = ziya_chart( @url, :size => "100x200" )
      html.index (/width=\"100\"/).should_not be_nil
      html.index (/height=\"200\"/).should_not be_nil      
    end    
  end
  
  describe "content_tag" do
    it "should output an html tag correctly" do
      content_tag( :div, content_tag( :h1, "Hello" ) ).should == "<div><h1>Hello</h1></div>"
    end
    
    it "should use leverage block to generate a tag" do
      content_tag( :div, :class => "fred", :id => "duh" ) do
        content_tag( :h2, "World" )
      end.should == "<div class=\"fred\" id=\"duh\"><h2>World</h2></div>"
    end
  end
  
end