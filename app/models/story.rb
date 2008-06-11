class Story < ActiveRecord::Base
  acts_as_state_machine :initial=>:new

  has_and_belongs_to_many :tasks , :before_add=>Proc.new{|p, d|  raise ActiveRecord::ActiveRecordError.new("Can't add a task to a passed story") if (p.current_state == :passed)}

  belongs_to :iteration

  validates_numericality_of :swag, :greater_than_or_equal_to=>0, :allow_nil=>true, :less_than=>10000

  validates_length_of :description, :maximum=>200, :allow_nil=>true

  validates_length_of :title, :within=>1..200

  state :new
  state :passed
  state :in_progress
  state :in_qc
  state :failed
  
  event :start do
    transitions :to=>:in_progress, :from=>:new
  end

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
    tasks.find_all{|x|x.reload.current_state != :new}.empty?
  end

  def has_incomplete?
    !tasks.find_all{|x| x.reload.current_state != :complete}.empty?
  end
  def has_in_progress?
    !tasks.find_all{|x| x.reload.current_state == :in_progress}.empty?
  end
  def all_complete?
    !has_incomplete?
  end
    
end
