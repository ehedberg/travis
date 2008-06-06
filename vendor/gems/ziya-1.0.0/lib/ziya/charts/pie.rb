# -----------------------------------------------------------------------------
# 
# -----------------------------------------------------------------------------
module Ziya::Charts
  class Pie < Base
    def initialize( license=nil, chart_id=nil)
      super( license, chart_id )
      @type = "pie"      
    end
  end
end