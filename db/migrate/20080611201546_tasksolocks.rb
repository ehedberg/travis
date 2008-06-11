class Tasksolocks < ActiveRecord::Migration
  def self.up
    add_column :tasks, :lock_version, :integer, :default=>0
  end

  def self.down
    remove_column :tasks, :lock_version
  end
end
