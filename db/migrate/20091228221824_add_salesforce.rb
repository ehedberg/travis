class AddSalesforce < ActiveRecord::Migration
  def self.up
    add_column :stories, :salesforce_url, :string, :limit=>100
    add_column :stories, :salesforce_ticket_nbr, :integer
    add_column :bugs, :salesforce_url, :string, :limit=>100
    add_column :bugs, :salesforce_ticket_nbr, :integer
  end

  def self.down
    remove_column :stories, :salesforce_url
    remove_column :stories, :salesforce_ticket_nbr
    remove_column :bugs, :salesforce_url
    remove_column :bugs, :salesforce_ticket_nbr
  end
end
