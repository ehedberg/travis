class AddStateToTask < ActiveRecord::Migration
  def self.up
    add_column :tasks, :state, :string, :limit=>20, :null=>false, :default=>"new"
  end

  def self.down
    remove_column :tasks, :state
  end
end
