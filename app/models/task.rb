class Task < ActiveRecord::Base
  acts_as_state_machine :initial=>:new

  attr_protected :state

  state :new,
    :enter=> Proc.new { |t| t.login = nil }
  state :in_progress,
    :enter=> Proc.new { |t| t.login = Session.current_login }
  state :complete

  event :start do
    transitions :to=>:in_progress, :from=>[:new]
  end

  event :stop do
    transitions :to=>:new, :from=>[:in_progress]
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

  def set_login
    puts "in set_login"
    self.login = Session.current_login
  end
  def unset_login
    puts "in unset_login"
    self.login = nil
  end

end
