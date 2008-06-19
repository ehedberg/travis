namespace :db do
  namespace :import do
    task :stories=>[:environment] do  |t|
      require 'fastercsv'
      FasterCSV.foreach("user_stories.csv") do |row|
        p row.inspect

      end


    end
  end
end
