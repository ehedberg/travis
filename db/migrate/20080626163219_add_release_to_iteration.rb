class AddReleaseToIteration < ActiveRecord::Migration
  def self.up
    add_column :iterations, :release_id, :integer
  end

  def self.down
    remove_column :iterations, :release_id
  end
end
