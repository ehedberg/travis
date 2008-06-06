# -----------------------------------------------------------------------------
# Generates necessary xml for a floating column chart
# -----------------------------------------------------------------------------
module Ziya::Charts
  class FloatingColumn < Base
    def initialize( license=nil, chart_id=nil)
      super( license, chart_id )
      @type = "floating column"      
    end
  end
end