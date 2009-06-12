class CreateBugs < ActiveRecord::Migration
  def self.up
    create_table :bugs do |t|
      t.column :title, :string, :limit=>200
      t.column :description, :text
      t.column :reported_by, :string, :limit=>200
      t.column :login, :string, :limit=>50
      t.column :state, :string, :limit=>20, :default=>'new', :null=>false
      t.column :swag, :decimal, :precision=>4, :scale=>2
      t.column :severity, :integer
      t.column :priority, :integer
      t.column :mnemonic, :string, :limit=>10
      t.column :completed_at, :date
      t.column :iteration_id, :integer
      t.column :lock_version, :integer, :default=>0, :null=>false
      t.timestamps
    end
  end

  def self.down
    drop_table :bugs
  end
end
