# == Schema Information
# Schema version: 20090204043205
#
# Table name: stories
#
#  id           :integer         not null, primary key
#  title        :string(200)     not null
#  description  :text
#  swag         :decimal(, )
#  created_at   :datetime
#  updated_at   :datetime
#  iteration_id :integer
#  state        :string(20)      default("new"), not null
#  completed_at :date
#  lock_version :integer         default(0)
#  nodule       :string(200)
#  mnemonic     :string(10)
#

class Story < ActiveRecord::Base
  attr_accessor :creator
  acts_as_taggable
  acts_as_state_machine :initial=>:new
  acts_as_solr :fields => [:title, :description], :include => :tasks
  has_many :audit_records

  validates_uniqueness_of :mnemonic
  has_and_belongs_to_many :tasks , 
    :before_add=>Proc.new{|s, t|  raise ActiveRecord::ActiveRecordError.new("Can't add a task to a passed story") if (s.current_state == :passed)}, 
    :after_add=>Proc.new{|s, t| s.task_changed! }, 
    :after_remove=>Proc.new{|s,t| s.task_changed!}
  
  before_create { |record| record.audit_records.build(:diff=>{:self=>[:nonexistent, :existent]}.to_yaml, :login=>'some guy' ) }
  
  after_create :set_mnemonic

  before_update { |record| 
    his = record.changes.dup
    his.delete(:updated_at)
    his.delete(:created_at)
    r = record.audit_records.build(:diff=>his.to_yaml, :login=>'some guy' ) 
    raise "invalid audit record?" unless r.valid?
  }

  belongs_to :iteration

  validates_numericality_of :swag, :greater_than_or_equal_to=>0, :allow_nil=>true, :less_than=>10000

  validates_uniqueness_of :title

  validates_presence_of :nodule
  validates_length_of :title, :within=>4..200

  state :new
  state :passed, :enter=>Proc.new{|s| s.update_attribute(:completed_at,   Date.today)}
  state :in_progress
  state :in_qc
  state :failed

  named_scope :unswagged, :conditions => ['swag IS NULL']

  event :fail do
    transitions :to=>:failed, :from=>:in_qc
  end

  event :pass do
    transitions :to=>:passed, :from=>:in_qc, :guard=>Proc.new{|s| s.all_complete?}
  end

  event :task_changed do
    transitions :to=>:new, :from=>:in_progress, :guard=>Proc.new{|s|s.all_new_tasks?}
    transitions :to=>:in_progress, :from=>:in_qc, :guard=>Proc.new{|s|s.has_incomplete?}
    transitions :to=>:in_progress, :from=>:new, :guard=>Proc.new{|s|s.has_in_progress?}
    transitions :to=>:in_qc, :from=>:in_progress, :guard=>Proc.new{|s|s.all_complete?}
    transitions :to=>:in_progress, :from=>:failed, :guard=>Proc.new{|s|s.has_in_progress?}
    transitions :to=>:in_progress, :from=>:passed, :guard=>Proc.new{|s|s.has_in_progress?}
  end

  def all_new_tasks?
    tasks.reload.find_all{|x|x.reload.current_state != :new}.empty?
  end

  def has_incomplete?
    !tasks.reload.find_all{|x| x.reload.current_state != :complete}.empty?
  end
  def has_in_progress?
    !tasks.reload.find_all{|x| x.reload.current_state == :in_progress}.empty?
  end
  def all_complete?
    !has_incomplete?
  end
  private 
  def set_mnemonic
    sname = self.nodule.squeeze.gsub(/[^a-zA-Z]/,'')[0,4]
    self.update_attribute(:mnemonic,("%s-%d"%[sname,self.id]).upcase)
  end
    
end
