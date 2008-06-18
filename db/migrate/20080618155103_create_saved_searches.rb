class CreateSavedSearches < ActiveRecord::Migration
  def self.up
    create_table :saved_searches do |t|
      t.column :query, :string, :limit=>200, :null=>false
      t.column :name, :string, :limit=>50, :null=>false
      t.column :query_type, :string, :limit=>10, :null=>false
      t.timestamps
    end
  end

  def self.down
    drop_table :saved_searches
  end
end
