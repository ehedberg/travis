# -----------------------------------------------------------------------------
# 
# -----------------------------------------------------------------------------
module Ziya::Charts
  class Polar < Base
    def initialize( license=nil, chart_id=nil)
      super( license, chart_id )
      @type = "polar"      
    end
  end
end