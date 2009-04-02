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
  belongs_to :story

  validates_presence_of :diff, :story_id, :login

  def diff_to_hash
    YAML::load(StringIO.new(diff)) || {}
  end
end
