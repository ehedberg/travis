class CreateAuditRecords < ActiveRecord::Migration
  def self.up
    create_table :audit_records do |t|
      t.string :login, :null=> true, :limit=>50
      t.references :story, :null => false
      t.text :diff, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :audit_records
  end
end
