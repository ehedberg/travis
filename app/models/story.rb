class Story < ActiveRecord::Base
  acts_as_state_machine :initial=>:new

  validates_uniqueness_of :mnemonic
  has_and_belongs_to_many :tasks , 
    :before_add=>Proc.new{|s, t|  raise ActiveRecord::ActiveRecordError.new("Can't add a task to a passed story") if (s.current_state == :passed)}, 
    :after_add=>Proc.new{|s, t| s.task_changed! }, 
    :after_remove=>Proc.new{|s,t| s.task_changed!}
  after_create :set_mnemonic


  belongs_to :iteration

  validates_numericality_of :swag, :greater_than_or_equal_to=>0, :allow_nil=>true, :less_than=>10000

  validates_uniqueness_of :title

  validates_length_of :title, :within=>1..200
  validates_presence_of :nodule
  validates_length_of :title, :within=>4..200

  state :new
  state :passed
  state :in_progress
  state :in_qc
  state :failed
  

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
