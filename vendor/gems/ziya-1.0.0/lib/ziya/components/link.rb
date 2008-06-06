# -----------------------------------------------------------------------------
# Sets up clickable areas on the chart.
#
# Holds any number of areas, each defining a rectangle and a URL to go to when the user
# clicks inside the rectangle. This can also be used to make refresh or print buttons.
#
# <tt></tt>:
#
# See http://www.maani.us/xml_charts/index.php?menu=Reference&submenu=link
# for additional documentation, examples and futher detail.
#
# Author:: Fernand Galiana
# Date::   Dec 15th, 2006
# -----------------------------------------------------------------------------
module Ziya::Components
  class Link < Base  
    has_attribute :areas
                     
    # -------------------------------------------------------------------------
    # Dump has_attribute into xml element
    def flatten( xml )
      if areas
        xml.link do
          areas.each { |area| area.flatten( xml ) }
        end
      end
    end
  end
end