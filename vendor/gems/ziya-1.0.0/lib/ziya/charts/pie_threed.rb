# -----------------------------------------------------------------------------
# Generates necessary xml for 3D pie chart 
# -----------------------------------------------------------------------------
module Ziya::Charts
  class PieThreed < Base
    def initialize( license=nil, chart_id=nil)
      super( license, chart_id )
      @type = "3d pie"      
    end
  end
end