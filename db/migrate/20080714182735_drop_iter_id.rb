class DropIterId < ActiveRecord::Migration
  def self.up
    remove_column :iterations, :release_id
  end

  def self.down
  end
end
