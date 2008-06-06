require 'rubygems'
require 'builder'
require 'spec'
require File.join( File.dirname(__FILE__), %w[.. lib ziya] )

# Init ZiYa...
::Ziya.initialize( :themes_dir => File.join( File.dirname(__FILE__), %w[themes] ) )