module TasksHelper
  def story_link(task)
    if (task.stories.empty?)
      "Unassigned"
    elsif (task.stories.length == 1)
      link_to("Show Story", story_path(task.stories.first.id))
    else
      "Stories"
    end
  end
end
