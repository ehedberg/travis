# -----------------------------------------------------------------------------
# Generates necessary xml for a StackColumn chart
# -----------------------------------------------------------------------------
module Ziya::Charts
  class Bar < Base
    def initialize( license=nil, chart_id=nil)
      super( license, chart_id )
      @type = "bar"      
    end
  end
end