# -----------------------------------------------------------------------------
# Generates necessary xml for scatter chart 
# -----------------------------------------------------------------------------
module Ziya::Charts
  class Scatter < Base
    def initialize( license=nil, chart_id=nil)
      super( license, chart_id )
      @type = "scatter"      
    end
  end
end         
