class StoryIndices < ActiveRecord::Migration
  def self.up
    add_index :stories, :iteration_id
    add_index :stories, :state
    add_index :tasks, :state
    add_index :stories_tasks, :story_id
    add_index :stories_tasks, :task_id
    add_index :iterations, :start_date
    add_index :iterations_releases, :iteration_id
    add_index :iterations_releases, :release_id

  end

  def self.down
  end
end
