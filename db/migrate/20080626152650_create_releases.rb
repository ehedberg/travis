class CreateReleases < ActiveRecord::Migration
  def self.up
    create_table :releases do |t|
      t.column :title, :string, :limit=>200, :null=>false
      t.timestamps
    end
  end

  def self.down
    drop_table :releases
  end
end
