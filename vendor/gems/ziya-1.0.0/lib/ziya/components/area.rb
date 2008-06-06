# -----------------------------------------------------------------------------
# Defines an area on a chart. Typically used to embed links and buttons
#
# Author:: Fernand Galiana
# Date::   Dec 15th, 2006
# -----------------------------------------------------------------------------
require 'ziya/components/base'

module Ziya::Components
  class Area < Base  
    has_attribute :x, :y, :width, :height, :url, :priority, :target, :text,
                  :font, :bold, :size, :color, :background_color, :alpha            
  end
end