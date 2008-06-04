class CreateIterations < ActiveRecord::Migration
  def self.up
    create_table :iterations do |t|
      t.column :title, :string, :limit=>200, :null=>false
      t.column :start_date, :date, :null=>false
      t.column :end_date, :date, :null=>false
      t.timestamps
    end
  end

  def self.down
    drop_table :iterations
  end
end
