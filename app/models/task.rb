# == Schema Information
# Schema version: 20090204043205
#
# Table name: tasks
#
#  id           :integer         not null, primary key
#  title        :string(200)     not null
#  description  :text            not null
#  created_at   :datetime
#  updated_at   :datetime
#  state        :string(20)      default("new"), not null
#  login        :string(50)
#  lock_version :integer         default(0)
#

class Task < ActiveRecord::Base
  acts_as_state_machine :initial=>:new

  attr_protected :state

  state :new, :enter=> Proc.new{ |t| t.login = nil; t.task_changed!}

  state :in_progress, :enter=> Proc.new{|t| t.login||=(User.current_user ? User.current_user.login : 'some guy'); t.task_changed! }

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
  validates_presence_of :title
  validates_length_of :title, :maximum=>200, :allow_nil=>true

  def task_changed!
    stories.each(&:task_changed!)
  end

end
