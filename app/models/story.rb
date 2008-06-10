class Story < ActiveRecord::Base
  acts_as_state_machine :initial=>:new

  has_and_belongs_to_many :tasks

  belongs_to :iteration

  validates_numericality_of :swag, :greater_than_or_equal_to=>0, :allow_nil=>true, :less_than=>10000

  validates_length_of :description, :maximum=>200, :allow_nil=>true

  validates_length_of :title, :within=>1..200

  state :new

  state :in_progress

  state :ready_for_qa
  
  event :start do
    transitions :to=>:in_progress, :from=>:new
  end

  event :assign_to_qa do
    transitions :to=>:ready_for_qa, :from=>:in_progress, :guard=> Proc.new{ |s| s.tasks.select{ |t| t.state != "complete" }.empty? }
  end
end
