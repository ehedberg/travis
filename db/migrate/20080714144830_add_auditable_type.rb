class AddAuditableType < ActiveRecord::Migration
  def self.up
    add_column :audit_records, :auditable_type, :string, :limit=>50
    add_index :audit_records, :auditable_type
  end

  def self.down
    remove_column :audit_records, :auditable_type
  end
end
