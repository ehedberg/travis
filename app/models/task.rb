class Task < ActiveRecord::Base
  acts_as_state_machine :initial=>:new

  attr_protected :state

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
    transitions :to=>:complete, :from=>[:in_progress]
  end

  event :reopen do
    transitions :to=>:in_progress, :from=>[:complete]
  end

  has_and_belongs_to_many :stories, :order=>"title asc"
  validates_presence_of :description, :title
  validates_length_of :title, :maximum=>200, :allow_nil=>true
  def task_changed!
    stories.each(&:task_changed!)
  end

end
