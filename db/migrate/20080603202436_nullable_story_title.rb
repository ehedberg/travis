class NullableStoryTitle < ActiveRecord::Migration
  def self.up
    change_column :stories, :title, :string, :limit=>200, :null=>false
  end

  def self.down
    change_column :stories, :title, :string, :limit=>200, :null=>true
  end
end
