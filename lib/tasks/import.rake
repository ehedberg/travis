namespace :db do
  namespace :import do
    task :stories=>[:environment] do  |t|
      require 'fastercsv'
      nodule=1
      phase=4
      swag=5
      user=6
      story=7
      more=8
      moremore=9
      Story.transaction do
        FasterCSV.foreach("user_stories.csv") do |row|
          next unless row[story]
          p 'saving %s'%row[story]
          desc =row[story]
          desc += "\n"+row[more] if row[more]
          desc += "\nuser: "+row[user] if row[user]
          s = Story.create(:title=>truncate(row[story], 200), :swag=>row[swag], :description=>desc, :nodule=>row[nodule])
        end
      end


    end
  end
end

def truncate(s, len)
  s[0,[s.length,len ].min]+'...'
end
