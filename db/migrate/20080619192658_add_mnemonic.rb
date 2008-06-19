class AddMnemonic < ActiveRecord::Migration
  def self.up
    add_column :stories, :mnemonic, :string, :limit=>10, :unique=>true
  end

  def self.down
    remove_column :stories, :mnemonic
  end
end
