# -----------------------------------------------------------------------------
# Generates necessary xml for parallel 3D column chart
# -----------------------------------------------------------------------------
module Ziya::Charts
  class ParallelThreedColumn < Base
    def initialize( license=nil, chart_id=nil)
      super( license, chart_id )
      @type = "parallel 3d column"      
    end
  end
end