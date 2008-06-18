class StoryAddArea < ActiveRecord::Migration
  def self.up
    add_column :stories, :area, :string, :limit=>200
  end

  def self.down
    remove_column :stories, :area
  end
end
