class AuditRecord < ActiveRecord::Base
  validates_presence_of :diff, :auditable, :login
  belongs_to :auditable, :polymorphic => true

  def diff_to_hash
    YAML::load(StringIO.new(diff)) || {}
  end
end
