# -----------------------------------------------------------------------------
# Generates necessary xml for a StackColumn chart
# -----------------------------------------------------------------------------
module Ziya::Charts
  class Column < Base
    def initialize( license=nil, chart_id=nil)
      super( license, chart_id )
      @type = "column"      
    end
  end
end