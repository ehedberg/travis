# -----------------------------------------------------------------------------
# Generates necessary xml for area chart 
# -----------------------------------------------------------------------------
require 'ziya/charts/base'

module Ziya::Charts
  class Area < Base
    def initialize( license=nil, chart_id=nil)
      super( license, chart_id )
      @type = "area"      
    end
  end
end