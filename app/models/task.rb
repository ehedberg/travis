class Task < ActiveRecord::Base
  include AASM

  aasm_initial_state :new

  aasm_state :new
  aasm_state :in_progress
  aasm_state :complete

  aasm_event :start do
    transitions :to=>:in_progress, :from=>[:new]
  end

  aasm_event :stop do
    transitions :to=>:new, :from=>[:in_progress]
  end

  aasm_event :finish do
    transitions :to=>:complete, :from=>[:in_progress]
  end

  aasm_event :reopen do
    transitions :to=>:in_progress, :from=>[:complete]
  end

  has_and_belongs_to_many :stories, :order=>"title asc"
  validates_presence_of :description, :title
  validates_length_of :title, :maximum=>200, :allow_nil=>true

  def login=(login)
    self[:login] = login
    self.start!
  end
end
