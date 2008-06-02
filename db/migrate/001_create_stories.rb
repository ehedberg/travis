class CreateStories < ActiveRecord::Migration
  def self.up
    create_table :stories do |t|
      t.column :title, :string, :limit=>200
      t.column :description, :text
      t.column :swag, :decimal, :precision=>4, :scale=>2

      t.timestamps
    end
  end

  def self.down
    drop_table :stories
  end
end
