# -----------------------------------------------------------------------------
# Generates necessary xml for floating bar chart
# -----------------------------------------------------------------------------
module Ziya::Charts
  class FloatingBar < Base
    def initialize( license=nil, chart_id=nil)
      super( license, chart_id )
      @type = "floating bar"      
    end
  end
end