class RenameTaskStateColumn < ActiveRecord::Migration
  def self.up
    rename_column :tasks, :aasm_state, :state
  end

  def self.down
    rename_column :tasks, :state, :aasm_state
  end
end
