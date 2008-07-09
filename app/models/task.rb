class Task < ActiveRecord::Base
  acts_as_state_machine :initial=>:new
  has_many :audit_records, :as => :auditable
  
  attr_protected :state

  before_create { |record| record.audit_records.build(:diff=>{:self=>[:nonexistent, :existent]}.to_yaml, :login=>Session.current_login ) }
  
  before_update { |record| 
    his = record.changes.dup
    his.delete(:updated_at)
    his.delete(:created_at)
    r = record.audit_records.build(:diff=>his.to_yaml, :login=>Session.current_login ) 
    raise "invalid audit record?" unless r.valid?
  }

  state :new, :enter=> Proc.new{ |t| t.login = nil; t.task_changed!}

  state :in_progress, :enter=> Proc.new{|t| t.login=Session.current_login; t.task_changed! }

  state :complete, :enter=> Proc.new{|t|t.task_changed!}

  event :start do
    transitions :to=>:in_progress, :from=>:new
  end

  event :stop do
    transitions :to=>:new, :from=>:in_progress
  end

  event :finish do
    transitions :to=>:complete, :from=>:in_progress
  end

  event :reopen do
    transitions :to=>:in_progress, :from=>:complete
  end

  has_and_belongs_to_many :stories, :order=>"title asc"
  validates_presence_of :description, :title
  validates_length_of :title, :maximum=>200, :allow_nil=>true

  def task_changed!
    stories.each(&:task_changed!)
  end

end
