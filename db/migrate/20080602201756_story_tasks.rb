class StoryTasks < ActiveRecord::Migration
  def self.up
    create_table :stories_tasks, :id=>false do |t|
      t.column :story_id, :integer, :null=>false
      t.column :task_id, :integer, :null=>false
    end
  end

  def self.down
    drop_table :stories_tasks
  end
end
