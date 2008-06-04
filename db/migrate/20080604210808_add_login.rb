class AddLogin < ActiveRecord::Migration
  def self.up
    add_column :tasks, :login, :string=>50, :null=>true
  end

  def self.down
    remove_column :tasks, :login
  end
end
