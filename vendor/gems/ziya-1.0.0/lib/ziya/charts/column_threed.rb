# -----------------------------------------------------------------------------
# Generates necessary xml for 3D column chart
# -----------------------------------------------------------------------------
module Ziya::Charts
  class ColumnThreed < Base
    def initialize( license=nil, chart_id=nil)
      super( license, chart_id )
      @type = "3d column"      
    end
  end
end