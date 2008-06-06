ziya
    by Fernand Galiana
    ziya.rubyforge.org

== DESCRIPTION:

ZiYa allows you to easily display graphs in your ruby based applications by leveraging
SWF Charts (http://www.maani.us/xml_charts/index.php). This plugin bundles version 4.7
of the flash library. Incorporating flash graphs in your app relieves the server by
allowing for delegating graph rendering to the client side. Using this plugin, you will
be able to easily create great looking charts for your application. You will also be able
to use the charts has a navigation scheme by embedding various link in the chart components
thus bring to the table an ideal scheme for reporting and dashboard like applications. Your
managers will love you for it !!

	Checkout the demo: http://ziya.liquidrail.com
	Video            : http://www.youtube.com/watch?v=axIMmMHdXzo ( Out of date but you'll get the basics... )
	Documentation    : http://ziya.liquidrail.com/rdoc ( New docs coming soon... )
	Forum            : http://groups.google.com/group/ziya-plugin


== FEATURES:

*  Allows you to style your charts just like you would an html page using css styles
   philosophy. Each chart can be associated with a YAML file that allows you to specify
   preferences based on SWF Charts properties. Chart style sheet reside under 
   public/charts/themes. By default all styling resides under the 'default' directory.
   Each chart type may have an associated YAML file. You can either inherit the default
   styles or define your own by specifying an id when you create your graph. The styles 
   will cascade thru your graph class hierarchy and override default preferences as you
   would in a style sheet.

   NOTE: XML/SWF charts are free of charge unless you need to use special features such
   as embedded links and printing. 
   The package cost $45 per domain and is well worth the investment.

*  We are leveraging ERB within the YAML file to provide access to the chart state. State
   can be passed in via the options hash when the graph is generated.
   You can also define your own methods in helpers/ZiyaHelpers. You can access these
   helper methods in your style file just like you would in a rails template.

*  Theme support. You can change the appearance and behavior of any charts by introducing
   new themes under the public/charts/themes directory.
      
== SYNOPSIS:
  
  When using within a rails application you will need to create a ziya.rb file in your
  config/initializers directory ( Rails 2.0 )
  
  ziya.rb:
  
    # Pull in the ZiYa gem framework
    gem "ziya", "~> 1.0.0"
    require 'ziya'

    # Initializes the ZiYa Framework
    Ziya.initialize( :logger      => RAILS_DEFAULT_LOGGER,
                     :helpers_dir => File.join( File.dirname(__FILE__), %w[.. .. app helpers ziya] ),
                     :themes_dir  => File.join( File.dirname(__FILE__), %w[.. .. public charts themes]) )  
  
   This will initialize the gem. You can log the output to stdout as well using the ZiYa bundled logger
   or specify a file ie File.join( File.dirname(__FILE__), %w[.. log ziya.log]. If you choose to user the 
   ZiYa logger, you can specify the :log_level option to either :warn :info :debug or :error.
   You will need to indicate your themes directory typically located under public/charts/themes or any location
   you'll choose. Otherwise ZiYa will used the default themes from the gem ie default or commando.
   Lastly you can specify a custom helper directory :helpers_dir, so you can use helper methods within your 
   ZiYa stylesheets.
   
*  Creating a chart
   
   blee_controller.rb
   
     class BleeController < ApplicationController
       helper Ziya::Helper
       
       # Callback from the flash movie to get the chart's data
       def load_chart
         chart = Ziya::Charts::Bar.new
         chart.add( :axis_category_text, %w[2006 2007 2008] )
         chart.add( :series, "Dogs", [10,20,30] )
         chart.add( :series, "Cats", [5,15,25] )
         
         respond_to do |fmt|
          fmt.xml => { render :xml => chart.to_xml }
       end
     end
     
   blee/index.html.erb
   
   <!-- Setups up flash in the html template -->
   <%= ziya_chart load_chart_url, :size => "300x200" -%>
   
   config/route.rb
   
   # Creates a named route for the chart.
   map.load_chart '/blee/load_chart', :controller => 'blee', :action => 'load_chart'
   
== REQUIREMENTS:

  ZiYa depends on the logging gem version > 0.7.1  

== INSTALL:

  sudo gem install ziya
  
  cd to your application directory and issue the following command
  
  > ziyafy
  
  This will copy the necessary themes and flash files to run ziya in your application 
  public/charts directory.


== LICENSE:

(The MIT License)

Copyright (c) 2008 FIXME (different license?)

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
