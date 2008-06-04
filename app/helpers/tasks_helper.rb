module TasksHelper
  def story_link(task)
    if (task.stories.empty?)
      "Unassigned"
    elsif (task.stories.length == 1)
      link_to("Show Story", story_path(task.stories.first.id))
    else
      str = link_to_function("Stories", "$('task_stories_#{task.id}').toggle()")
      str << stories_listing(task)
      str
    end
  end

  def stories_listing(task)
    list = "<div id='task_stories_#{task.id}' style='display:none;'><ul>"
    task.stories.each do |story|
      list << "<li>"
      list <<  link_to(h(story.title), story_path(story))
      list << "</li>"
    end
    list << "</ul></div>"
  end
end
