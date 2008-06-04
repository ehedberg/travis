class StoryTasks < ActiveRecord::Migration
  def self.up
    create_table :stories_tasks, :id=>false do |t|
      t.column :story_id, :number, :null=>false
      t.column :task_id, :number, :null=>false

      t.timestamps
    end
  end

  def self.down
    drop_table :stories_tasks
  end
end
