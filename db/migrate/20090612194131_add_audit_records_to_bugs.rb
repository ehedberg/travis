class AddAuditRecordsToBugs < ActiveRecord::Migration
  def self.up
    rename_column :audit_records, :story_id, :auditable_id
  end

  def self.down
    rename_column :audit_records, :auditable_id, :story_id
  end
end
