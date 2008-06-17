# -----------------------------------------------------------------------------
# Generates necessary html flash tag to support ZiYa
#
# TODO !! Rewrite to use content tag block instead...
#
# Author: Fernand Galiana
# -----------------------------------------------------------------------------
require 'cgi'
require 'erb'

module Ziya
  module Helper    
    # const accessor...
    def xml_swf()    "%s/charts.swf?library_path=%s/charts_library&xml_source=%s"; end
    
    # -------------------------------------------------------------------------------------
    # Generates chart object tag with given url to fetch the xml data  
    # -------------------------------------------------------------------------------------            
    def ziya_chart( url, chart_options = {} )
      options = { :width          => "400",
                  :height         => "300",
                  :align          => "left",
                  :class          => "",        
                  :id             => "ziya_chart",
                  :swf_path       => chart_path,
                  :cache          => false,
                  :timeout        => nil,
                  :use_stage      => true,
                  :style          => ""
                }.merge!(chart_options)

      # Escape url
      url = CGI.escape( url.gsub( /&amp;/, '&' ) )

      # Set the wmode to opaque if a bgcolor is specified. If not set to
      # transparent mode unless user overrides it
      if options[:bgcolor]
        options[:wmode] = "opaque" unless options[:wmode]
      else
        options[:wmode]   = "transparent" unless options[:wmode]
        options[:bgcolor] = "#FFFFFF"
      end
      color_param  = tag( 'param', {:name => 'bgcolor', :value => options[:bgcolor]}, true )
      color_param += tag( 'param', {:name  => "wmode", :value => options[:wmode]}, true )

      # Check args for size option (Submitted by Sam Livingston-Gray)                                  
      if options[:size] =~ /(\d+)x(\d+)/
        options[:width]  = $1
        options[:height] = $2
        options.delete :size
      end
                             
      xml_swf_path = xml_swf % [options[:swf_path], options[:swf_path], url ]
      xml_swf_path << "&timestamp=#{Time.now.to_i}" if options[:cache] == false
      xml_swf_path << "&timeout=#{options[:timeout]}" if options[:timeout]
      xml_swf_path << "&stage_width=#{options[:width]}&stage_height=#{options[:height]}" if options[:use_stage] == true 
      content_tag( 'object',
        tag( 'param',
         {:name  => "movie",
         :value =>  xml_swf_path}, true ) +
        tag( 'param', 
         {:name  => "quality",
         :value => "high"}, true )  +
        content_tag( 'embed', nil, 
         :src           => xml_swf_path,
         :quality       => 'high', 
         :bgcolor       => options[:bgcolor],
         :wmode         => options[:wmode], 
         :width         => options[:width], 
         :height        => options[:height], 
         :name          => options[:id], 
         :swLiveConnect => "true", 
         :type          => "application/x-shockwave-flash",
         :pluginspage   => "http://www.macromedia.com/go/getflashplayer") +
        color_param,
        :classid     => class_id,
        :codebase    => codebase,
        :data        => xml_swf_path, 
        :style       => options[:style],
        :width       => options[:width], :height => options[:height], 
        :stage_width => options[:width], :stage_height => options[:height], :id => options[:id] )
    end   
    
    # =========================================================================
    private                               

       # Const accessors...
       def chart_path() 
        "/charts"
       end       
       def class_id()   "clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" end
       def codebase()   "http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,0,0"; end
    
      # All this stolen form rails to make Ziya work with other fmks....    
      def tag(name, options = nil, open = false, escape = true)
       "<#{name}#{tag_options(options, escape) if options}" + (open ? ">" : " />")
      end    
      
      def escape_once(html)
        html.to_s.gsub(/[\"><]|&(?!([a-zA-Z]+|(#\d+));)/) { |special| escape_chars[special] }
      end
      
      def tag_options(options, escape = true)
        unless !options or options.empty?
          attrs = []
          if escape
            options.each do |key, value|
              next unless value
              key = key.to_s
              value = escape_once(value)
              attrs << %(#{key}="#{value}")
            end
          else
            attrs = options.map { |key, value| %(#{key}="#{value}") }
          end
          " #{attrs.sort * ' '}" unless attrs.empty?
        end
      end
      
      def content_tag(name, content_or_options_with_block = nil, options = nil, escape = true, &block)
        if block_given?
          options = content_or_options_with_block if content_or_options_with_block.is_a?(Hash)
          content = capture_block(&block)
          content_tag = content_tag_string(name, content, options, escape)
          block_is_within_action_view?(block) ? concat(content_tag, block.binding) : content_tag
        else
          content = content_or_options_with_block
          content_tag_string(name, content, options, escape)
        end
      end
      
      def capture_block( *args, &block )
          block.call(*args)
      end
      
      def content_tag_string(name, content, options, escape = true)
        tag_options = tag_options(options, escape) if options
        "<#{name}#{tag_options}>#{content}</#{name}>"
      end

      def block_is_within_action_view?(block)
        eval("defined? _erbout", block.binding)
      end  
      
      def escape_chars 
        { '&' => '&amp;', '"' => '&quot;', '>' => '&gt;', '<' => '&lt;' }
      end          
  end
end
