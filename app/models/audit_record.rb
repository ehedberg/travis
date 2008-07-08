class AuditRecord < ActiveRecord::Base
  belongs_to :story

  validates_presence_of :diff, :story_id, :login
end
