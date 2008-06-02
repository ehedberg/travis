class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.column :title, :string, :limit=>200, :null=>false
      t.column :description, :text, :null=>false
      
      t.timestamps
    end
  end

  def self.down
    drop_table :tasks
  end
end
