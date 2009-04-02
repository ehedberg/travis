class Story < ActiveRecord::Base
  generator_for :nodule, "foo"
  generator_for :title, :method => :generate_title
  
  def self.generate_title
    @last_title ||= "Generated title 000"
    @last_title.succ
  end
end