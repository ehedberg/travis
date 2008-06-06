# -----------------------------------------------------------------------------
# Draws some text on a chart
#
# Author:: Fernand Galiana
# Date::   Dec 15th, 2006
# -----------------------------------------------------------------------------
module Ziya::Components
  class Text < Base  
    has_attribute :layer, :transition, :delay, :duration, :x, :y, :width,
                  :height, :h_align, :v_align, :rotation, :font, :bold, :size,
                  :color, :alpha, :text              
  end
end