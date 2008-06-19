class RenameArea < ActiveRecord::Migration
  def self.up
    rename_column :stories, :area, :nodule
  end

  def self.down
    rename_column :stories, :nodule, :area
  end
end
