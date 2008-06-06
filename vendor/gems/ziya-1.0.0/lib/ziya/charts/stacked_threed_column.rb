# -----------------------------------------------------------------------------
# Generates necessary xml for a stacked 3d column chart
# -----------------------------------------------------------------------------
module Ziya::Charts
  class StackedThreedColumn < Base
    def initialize( license=nil, chart_id=nil)
      super( license, chart_id )
      @type = "stacked 3d column"      
    end
  end
end