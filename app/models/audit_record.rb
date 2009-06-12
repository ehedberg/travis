# == Schema Information
# Schema version: 20090204043205
#
# Table name: audit_records
#
#  id             :integer         not null, primary key
#  login          :string(50)
#  story_id       :integer         not null
#  diff           :text            not null
#  created_at     :datetime
#  updated_at     :datetime
#  auditable_type :string(50)
#

class AuditRecord < ActiveRecord::Base
  belongs_to :auditable, :polymorphic=>true

  validates_presence_of :diff, :auditable_id, :login

  def diff_to_hash
    YAML::load(StringIO.new(diff)) || {}
  end
  
  def AuditRecord.build_it(auditable_record)
    his = auditable_record.changes.dup
    his.delete('updated_at')
    his.delete('created_at')
    his.delete('swag') if auditable_record.respond_to?('swag') && auditable_record.swag_was.blank? && auditable_record.swag.blank?
    r = auditable_record.audit_records.build(:diff=>his.to_yaml, :login=>(User.current_user ? User.current_user.login : 'some guy')) 
    raise "invalid audit record?" unless r.valid?
  end
end
