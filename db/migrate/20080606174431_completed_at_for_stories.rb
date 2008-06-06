class CompletedAtForStories < ActiveRecord::Migration
  def self.up
    add_column :stories, :completed_at, :date
  end

  def self.down
    remove_column :stories, :completed_at
  end
end
