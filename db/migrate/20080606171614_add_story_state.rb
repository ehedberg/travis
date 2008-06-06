class AddStoryState < ActiveRecord::Migration
  def self.up
    add_column :stories, :state, :string, :limit=>20, :null=>false, :default=>'new'
  end

  def self.down
    remove_column :stories, :state
  end
end
