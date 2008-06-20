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
      fi = Iteration.find(:first, :order=>'start_date asc')
      Story.transaction do
        FasterCSV.foreach("user_stories.csv") do |row|
          next unless row[story]
          desc =row[story]
          desc += "\n"+row[more] if row[more]
          desc += "\nuser: "+row[user] if row[user]
          s = Story.create(:title=>truncate(row[story], 199), :swag=>row[swag], :description=>desc, :nodule=>row[nodule])
          s.save!
          fi.stories << s if row[phase].to_i == 1
        end
      end
      p "imported #{Story.count} stories"
    end
  end
end

def truncate(s, len)
  s[0,[s.length-3,len-3 ].min]+'...'
end
