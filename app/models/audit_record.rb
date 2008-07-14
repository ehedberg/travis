class AuditRecord < ActiveRecord::Base
  belongs_to :story

  validates_presence_of :diff, :story_id, :login

  def diff_to_hash
    YAML::load(StringIO.new(diff)) || {}
  end
end
