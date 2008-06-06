# -----------------------------------------------------------------------------
# == Ziya::Charts::Base
#
# Charts mother ship
#
# TODO !! Match helpers with chart class name
# TODO !! Add accessor for specifying refresh look and data links on comps
#
# Author:: Fernand Galiana
# Date::   Dec 15th, 2006
# -----------------------------------------------------------------------------
require 'ziya/helpers/base_helper'
require 'yaml'

module Ziya::Charts
  class Base
    include Ziya::Helpers::BaseHelper
    
    # =========================================================================                
    protected      
      # defines the various chart components
      def self.declare_components
        @components = [:axis_category, :axis_ticks, :axis_value, :chart_rect, 
                       :chart_border, :chart_grid_h, :chart_grid_v, 
                       :chart_transition, :chart_value, :legend_rect, 
                       :legend_transition, :legend_label, :draw, :series_color, 
                       :series_gap, :series_switch, :series_explode, :chart_pref, 
                       :live_update, :link_data, :link]                              
        @components.each { |a| attr_accessor a }      
      end    
      declare_components

    # =========================================================================    
    public
    
    attr_accessor :license, :id, :theme, :options, :size
    attr_reader   :type

    # -------------------------------------------------------------------------
    # Create a new chart.
    # license  - the XML/SWF charts license
    # title    - the chart title
    # chart_id - the id of the chart used to associate a style with the chart.
    # If chart_id is specified the framework will attempt to load the chart styles
    # from public/themes/theme_name/chart_id.yml 
    def initialize( license=nil, chart_id=nil ) 
      @id      = chart_id
      @license = license
      @options = {}
      @theme   = default_theme
      initialize_components
      load_helpers( Ziya.helpers_dir ) if Ziya.helpers_dir
    end
                
    # class component accessor...
    def self.components
      @components
    end
    
    # -------------------------------------------------------------------------
    # Default ZiYa theme
    def default_theme
      File.join( Ziya.themes_dir, %w[default] )
    end
    
    # -------------------------------------------------------------------------
    # Load up ERB style helpers
    def load_helpers( helper_dir )      
      Dir.foreach(helper_dir) do |helper_file| 
        next unless helper_file =~ /^([a-z][a-z_]*_helper).rb$/
        Ziya.logger.debug( ">>> ZiYa loading custom helper `#{$1}" )        
        require_dependency File.join(helper_dir, $1)
        helper_module_name = $1.to_s.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
        # if Ziya::Helpers.const_defined?(helper_module_name)
        Ziya.logger.debug( "Include module #{helper_module_name}")
        Ziya::Charts::Base.class_eval("include #{helper_module_name}") 
        # end
      end
    end    
                    
    # -------------------------------------------------------------------------
    # Add chart components such as x and y axis labels, data points and chart 
    # labels.     
    # 
    # Example:
    #   my_chart.add( :axis_category_text, ['2004', '2005', '2006'] ) 
    #   my_chart.add( :series, 'series A', [ 10, 20, 30], [ '10 dogs', '20 cats', '30 rats'] )
    #   my_chart.add( :axis_value_text, [ 'my dogs', 'my cats', 'my rats'] )
    #   my_chart.add( :user_data, :mykey, "Fred" )
    #
    #   This will display a bar chart with x axis ticks my dogs, my cats, my fox and
    #   y axis values 2004, 2005, 2006. The labels on the bars will read 10 dogs, 
    #   20 cats, 30 rats
    #
    # The <tt>args</tt> must contain certain keys for the chart
    # to be display correctly. The keys are defined as follows:
    # <tt>:axis_category_text</tt>::   Array of strings representing the x/y axis
    #                                  ticks dependending on the chart type. This 
    #                                  value is required.
    # <tt>:series</tt>::               Specifies the series name and chart data points.
    #                                  The series name will be used to display chart legends.
    #                                  You must have at least one of these tag defined.
    #                                  You may also specify an array of strings to identifies the 
    #                                  custom labels that will be used on top of the chart 
    #                                  elements.                                  
    # <tt>:axis_value_text</tt>::      Array of strings representing the ticks on the x/y
    #                                  axis depending on the chart type. This is symmetrical
    #                                  to the <tt>axis_category_text</tt> tag for the opposite
    #                                  chart axis.     
    # <tt>:user_data</tt>::            Used to make user data available to the ERB templates in
    #                                  the chart stylesheet yaml file. You must specify a key symbol
    #                                  and an ad-hoc value. The key will be used with the @options
    #                                  hash to access the user data.  
    # <tt>:composites</tt>::           Embeds multiple charts within the given chart.                                 
    # <tt>:chart_types</tt>::          Specify the chart types per series. This option should                        
    #                                  only be used with Mixed Charts !!    
    # <tt>:theme</tt>::                Specify the use of a given theme
    #
    # TODO Validation categories = series, series = labels, etc...
    # BOZO !! If you have a series you'll need to define an axis_category for it
    def add( *args )
      directive = args.shift
      case directive
        when :axis_category_text
          categories = args.first.is_a?(Array) ? args.shift : []
          raise ArgumentError, "Must specify an array of categories" if categories.empty?
          categories.insert( 0, nil )
          @options[directive] = categories
        when :composites
          composites = args.first.is_a?(Array) ? args.shift: []
          raise ArgumentError, "Must specify an array of urls for the composite chart(s)" if composites.empty?
          @options[directive] = composites
        when :axis_value_text
          values = args.first.is_a?(Array) ? args.shift : []
          raise ArgumentError, "Must specify an array of values" if values.empty?
          @options[directive] = values
        when :series
          legend = args.first.is_a?(String) ? args.shift : ""
          raise ArgumentError, "Must specify a series name" if legend.empty?
          points = args.first.is_a?(Array) ? args.shift : []
          raise ArgumentError, "Must specify data points" if points.empty?
          points.insert( 0, legend )
          labels      = args.first.is_a?(Array) ? args.shift : []
          count       = "_#{sprintf( '%04d', next_series_count )}_#{legend}"
          series_name = "series#{count}"
          labels_name = "labels#{count}" unless labels.empty?
          @options[series_name.to_sym] = points
          @options[labels_name.to_sym] = labels unless labels.empty?
        when :user_data
          key = args.first.is_a?(Symbol) ? args.shift : ""
          raise ArgumentError, "Must specify a key" if key.to_s.empty?
          value = args.shift
          # raise ArgumentError, "Must specify a value" if value.empty?
          @options[key] = value
        when :styles
          styles = args.first.is_a?(String) ? args.shift : ""
          raise ArgumentError, "Must specify a set of styles" if styles.to_s.empty?          
          @options[:styles] = styles   
        when :chart_types
          types = args.first.is_a?(Array) ? args.shift : []
          raise ArgumentError, "Must specify a set of chart types" if types.to_s.empty?          
          @options[:chart_types] = types                        
        when :theme
          theme = args.first.is_a?(String) ? args.shift : ""
          raise ArgumentError, "Must specify a theme name" if theme.to_s.empty?          
          @theme = "#{Ziya.themes_dir}/#{theme}"
        else raise ArgumentError, "Invalid directive must be one of " + 
                                 ":axis_category, :axis_value, :series, :user_data"
      end 
    end
        
    # -------------------------------------------------------------------------
    # Set up theme for overall look and feel
    # <tt>theme_name</tt> the name of the directory that contains the chart styles 
    def self.theme( theme_name )
      @theme = "#{Ziya.themes_dir}/#{theme_name}"
    end
    
    # -------------------------------------------------------------------------
    # Return the local theme if set or the global theme otherwise
    def theme
      @theme || @@theme
    end
        
    # ---------------------------------------------------------------------------
    # Spews the graph specification to xml  
    # <tt>:partial</tt>::  You can specify this option to only update parts of the charts
    #                      that have actually changed. This is useful for live update and
    #                      link update where you may not need to redraw the whole chart.
    def to_s( options={} )
      @partial = options[:partial] || false
      @xml     = Builder::XmlMarkup.new
      @xml.chart do
        @xml.license( @license ) unless @license.nil?
        if !@type.nil?
          @xml.chart_type( @type )              
        elsif @options[:chart_types].is_a? Array and ! @options[:chart_types].empty?
          @xml.chart_type do   
            @options[:chart_types].each { |type| @xml.string( type ) }   
          end
        end                
        setup_lnf
        setup_series
      end
      @xml.to_s.gsub( /<to_s\/>/, '' )
    end                                   
    
    # -------------------------------------------------------------------------
    # Synonym for to_s
    alias to_xml to_s  
                            
    # =========================================================================
    private

    # -------------------------------------------------------------------------
    # Make sure series appear in the right order
    def next_series_count
      count = 1
      @options.keys.each{ |k| count+=1 unless k.to_s.index( "series_").nil? }
      count
    end

    # -------------------------------------------------------------------------
    # Inflate object state based on object hierarchy
    def setup_state( state )
      override = self.class.name == state.class.name
      Base.components.each do |comp| 
        instance_eval "#{comp}.merge( state.#{comp}, override ) unless state.#{comp}.nil?" 
      end
    end    
            
    # -------------------------------------------------------------------------
    # Load yaml file associated with class if any
    def inflate( clazz, theme, instance=nil )
      class_name  = underscore(clazz.to_s.gsub( /Ziya::Charts/, '' )).gsub( /\//, '' )      
      class_name += '_chart' unless class_name.match( /.?_chart$/ ) 
      begin
        file_name = "#{theme}/#{class_name}"
        file_name = "#{theme}/#{instance}" unless instance.nil?
        Ziya.logger.debug ">>> Ziya attempt to load style sheet file '#{file_name}"        
        yml = IO.read( "#{file_name}.yml" )
        load = YAML::load( erb_render( yml ) )
        Ziya.logger.info ">>> ZiYa [loading styles] -- #{file_name}.yml"        
        return load
      rescue SystemCallError => boom
        ; # ignore if no style file...
      rescue => bang
        Ziya.logger.error ">>> ZiYa -- Error encountered loading file `#{file_name} -- #{bang}" 
        bang.backtrace.each { |l| Ziya.logger.error( l ) }
      end
      nil
    end
        
    # -------------------------------------------------------------------------
    # Parse erb template if any
    def erb_render(fixture_content)
      b = binding
      ERB.new(fixture_content).result b      
    end
                              
    # -------------------------------------------------------------------------
    # Generates xml element for given data set
    def gen_data_points( series_name )
      value = @options[series_name]
      @xml.row do
        if value.respond_to? :each
          value.each do |c|            
            @xml.null if c.nil?
            @xml.string( c ) if c.instance_of? String 
            @xml.number( c ) if c.respond_to? :zero?
          end
        else
          @xml.string( value )
        end
      end              
    end
            
    # -------------------------------------------------------------------------
    # Generates custom axis values
    def gen_axis_value_text( values )
      return if values.nil? or values.empty?
      @xml.axis_value_text do 
        values.each { |v| @xml.string( v ) }
      end
    end
        
    # -------------------------------------------------------------------------
    # Check if the series are named
    def named_series?( names )
      names.each do |name|
        next unless name.to_s.index( 'series_' )
        return @options[name][0].instance_of?(String) if @options[name] and !@options[name].empty?
      end
      false
    end
    
    # -------------------------------------------------------------------------
    # Check if the options have custom labels ie :label_xxx tag
    def has_labels( names )
      names.each do |name|
        next unless name.to_s.index( 'labels_' )
        return @options[name].size if @options[name] and !@options[name].empty?
      end
      0
    end    
    
    # -------------------------------------------------------------------------
    # Generates custom labels
    def gen_labels( series_name, is_default=false )
      cltn  = @options[series_name]
      cltn.insert( 0, nil ) unless is_default
      @xml.row do        
        cltn.each { |c| ((c.nil? or c.to_s.empty?) ? @xml.null : @xml.string( c )) }
      end              
    end    
    
    # ------------------------------------------------------------------------
    # Generates default series labels
    def gen_default_labels( size )
      labels = []
      size.times { |i| labels << nil }
      @xml.row do        
        labels.each { |c| @xml.null }
      end     
    end                
    
    # -------------------------------------------------------------------------
    # Lay down graph data points and labels if any
    # TODO Validate series sizes/label sizes
    def setup_series
      keys = @options.keys.sort { |a,b| a.to_s <=> b.to_s }
      named_series = named_series?( keys )
      
      raise "You must specify an axis_category_text with your series." if named_series and ! @options[:axis_category_text]
      
      unless @options[:axis_category_text].nil?
        @xml.chart_data do 
          # Setup axis categories        
          # @options[:axis_category_text].insert( 0, nil ) if named_series
          gen_data_points( :axis_category_text )
          keys.each do |k| 
            gen_data_points( k ) unless k.to_s.index( 'series_' ).nil?
          end
        end  
      end

      size = has_labels( keys )
      if size > 0 
        @xml.chart_value_text do
          labels = []
          (1..(size-1)).each { |i| labels << '' }
          @options[:labels] = labels
          gen_labels( :labels, true )
        
          # Generates series labels if specified
          keys.each do |k|
            next unless k.to_s.index( /^series/ )
            label  = k.to_s.gsub( /series/, 'labels' ).to_sym
            unless @options[label].nil?
              gen_labels( label ) 
            else
              gen_default_labels( size )
            end
          end
        end    
      end
    end
    
    # -------------------------------------------------------------------------
    # Walk up class hierarchy to find chart inheritance classes
    def ancestors
      excludes = [ "Kernel", "Object", "CommonUtils" ]
      ancestors = self.class.ancestors.reverse
      list = []
      ancestors.each { |a| list << a unless excludes.include? a.to_s }
      list
    end
    
    # -------------------------------------------------------------------------
    # Load up look and feel data
    def load_lnf     
      unless @partial
        ancestors.each do |super_class|
          if ( super_class == self.class )
            # Load class instance prefs
            o = inflate( super_class, theme )
            setup_state( o ) unless o.nil? 
            # Now load instance prefs if any
            unless id.nil?
              o = inflate( super_class, theme, id )
              setup_state( o ) unless o.nil?        
            end
          else
            o = inflate( super_class, theme, nil )
            setup_state( o ) unless o.nil?
          end
        end      
      end
      # Additional styles specified ? if so load them
      unless @options[:styles].nil?
        o = YAML::load( erb_render( @options[:styles] ) )
        setup_state( o ) unless o.nil?
      end
    end
        
    # -------------------------------------------------------------------------
    # Generates xml for look and feel data
    def setup_lnf
      load_lnf
      if @options[:axis_value_text] and ! @options[:axis_value_text].empty?
        gen_axis_value_text( @options[:axis_value_text] )
      end
      
      unless @partial
        Base.components.each do |comp|          
          next unless self.send( comp ).configured? # => Don't include non configured components
          if comp == :draw
            instance_eval "#{comp}.flatten( @xml, @options[:composites] )"
          else
            instance_eval "#{comp}.flatten( @xml )"
          end
        end
      end      
    end

    # -------------------------------------------------------------------------  
    def initialize_components
      # Setup instance vars
      Base.components.each do |comp|
        instance_var = lambda { |v| self.instance_eval{ instance_variable_set "@#{comp}", v } }
        instance_var.call(Ziya::Components.const_get(classify(comp)).new)
      end      
    end       
  end
end
