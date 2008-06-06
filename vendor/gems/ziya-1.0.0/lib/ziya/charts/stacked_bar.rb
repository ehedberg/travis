# -----------------------------------------------------------------------------
# Generates necessary xml for a stacked bar chart
# -----------------------------------------------------------------------------
module Ziya::Charts
  class StackedBar < Base
    def initialize( license=nil, chart_id=nil)
      super( license, chart_id )
      @type = "stacked bar"      
    end
  end
end