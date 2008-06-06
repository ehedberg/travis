# -----------------------------------------------------------------------------
# Generates necessary xml for a StackColumn chart
# -----------------------------------------------------------------------------
module Ziya::Charts
  class Line < Base
    def initialize( license=nil, chart_id=nil)
      super( license, chart_id )
      @type = "line"      
    end
  end
end