class Storyolocks < ActiveRecord::Migration
  def self.up
    add_column :stories, :lock_version, :integer, :default=>0
  end

  def self.down
    remove_column :stories, :lock_version
  end
end
