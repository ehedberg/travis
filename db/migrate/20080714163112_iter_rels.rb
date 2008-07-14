class IterRels < ActiveRecord::Migration
  def self.up
    create_table :iterations_releases, :force=>true do |t|
      t.integer :iteration_id, :null=>false
      t.integer :release_id, :null=>false
    end
  end

  def self.down
  end
end
