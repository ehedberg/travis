class Bug < ActiveRecord::Base
  acts_as_state_machine :initial=>:new
  acts_as_taggable

  belongs_to :iteration

  attr_protected :state, :login

  validates_length_of :title, :within=>4..200
  validates_length_of :reported_by, :maximum=>200, :allow_nil=>true
  validates_numericality_of :swag, :greater_than_or_equal_to=>0, :allow_nil=>true, :less_than=>10000
  validates_numericality_of :severity, :greater_than_or_equal_to=>1, :allow_nil=>true, :less_than_or_equal_to=>4
  validates_numericality_of :priority, :greater_than_or_equal_to=>1, :allow_nil=>true, :less_than_or_equal_to=>4

  after_create :set_mnemonic

  named_scope :unswagged, :conditions => ['swag IS NULL']

  state :new
  state :held
  state :waiting_for_fix, :enter=>Proc.new{|b| b.login = nil; b.save!}
  state :in_progress, :enter=>Proc.new{|b| b.login = (User.current_user ? User.current_user.login : 'some guy'); b.save!}
  state :in_qc
  state :passed, :enter=>Proc.new{|b| b.login = nil; b.save!}

  event :hold do
    transitions :to=>:held, :from=>:new
    transitions :to=>:held, :from=>:waiting_for_fix
  end
  event :approve do
    transitions :to=>:waiting_for_fix, :from=>:new
    transitions :to=>:waiting_for_fix, :from=>:held
  end
  event :start do
    transitions :to=>:in_progress, :from=>:waiting_for_fix
  end
  event :stop do
    transitions :to=>:waiting_for_fix, :from=>:in_progress
  end
  event :finish do
    transitions :to=>:in_qc, :from=>:in_progress
  end
  event :fail do
    transitions :to=>:in_progress, :from=>:in_qc
  end
  event :pass do
    transitions :to=>:passed, :from=>:in_qc
  end
  
  def severity_text
    case self.severity
    when 1 
      'Show Stopper'
    when 2 
      'Annoying'
    when 3 
      'Work-Around Exists'
    when 4 
      'Aesthetic'
    else
      'Unknown'
    end
  end

  def priority_text
    case self.priority
    when 1 
      'Critical'
    when 2 
      'High'
    when 3 
      'Medium'
    when 4 
      'Low'
    else
      'Unknown'
    end
  end

  private 
  def set_mnemonic
    self.update_attribute(:mnemonic, ("BUG-%d"%[self.id]))
  end
  
  def self.per_page
    20
  end
end
