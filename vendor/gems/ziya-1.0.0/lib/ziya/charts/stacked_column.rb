# -----------------------------------------------------------------------------
# Generates necessary xml for a stack column chart
# -----------------------------------------------------------------------------
module Ziya::Charts
  class StackedColumn < Base
    def initialize( license=nil, chart_id=nil)
      super( license, chart_id )
      @type = "stacked column"      
    end
  end
end