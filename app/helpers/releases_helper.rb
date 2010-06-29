module ReleasesHelper
  def iteration_link(release, exclude=[])
    if (release.iterations.empty?)
      "Unassigned"
    elsif ((release.iterations-exclude ).size == 1)
      link_to(release.iterations.first.title, iteration_path(release.iterations.first))
    else 
      iterations = release.iterations - exclude
      str = link_to_function(truncate(iterations.map(&:title).join(', ')), "$('iteration_releases_#{release.id}').toggle()", :class=>'expando')
      str2 = iterations_listing(release, (release.iterations-exclude))
      "#{str} #{str2}"
    end
  end

  def iterations_listing(release,iterations)
    list = "<div id='iteration_releases_#{release.id}' style='display:none;'><ul>"
    iterations.each do |iter|
      list << "<li>"
      list <<  link_to(h(iter.title), iteration_path(iter))
      list << "</li>"
    end
    list << "</ul></div>"
  end

end
