namespace :db do
  task :genmn=>[:environment] do
    Story.find(:all).each{|x|x.send(:set_mnemonic);p x.mnemonic}
  end
end
