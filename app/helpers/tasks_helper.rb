module TasksHelper
  def story_link(task, exclude=[])
    if (task.stories.empty?)
      "Unassigned"
    elsif ((task.stories-exclude ).size == 1)
      link_to(task.stories.first.title, story_path(task.stories.first))
    else 
      stories = task.stories - exclude
      str = link_to_function(truncate(stories.map(&:title).join(', ')), "$('task_stories_#{task.id}').toggle()", :class=>'expando')
      str2 = stories_listing(task, (task.stories-exclude))
      "#{str} #{str2}"
    end
  end

  def stories_listing(task,stories)
    list = "<div id='task_stories_#{task.id}' style='display:none;'><ul>"
    stories.each do |story|
      list << "<li>"
      list <<  link_to(h(story.title), story_path(story))
      list << "</li>"
    end
    list << "</ul></div>"
  end
end
