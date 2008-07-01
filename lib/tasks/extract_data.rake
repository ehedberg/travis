namespace :db do
  namespace :extract  do
    task :fixtures => :environment do 
      sql = "SELECT * FROM %s" 
      skip_tables = ["schema_info"] 
      ActiveRecord::Base.establish_connection 
      (ActiveRecord::Base.connection.tables - skip_tables).each do |table_name| 
        i = Time.now.to_i.to_s
        File.open("#{RAILS_ROOT}/seed/#{table_name}.yml", 'w') do |file| 
          data = ActiveRecord::Base.connection.select_all(sql % table_name) 
          file.write data.inject({}) { |hash, record| 
            hash["#{table_name}_#{i.succ!}"] = record 
            hash 
          }.to_yaml 
        end 
      end 
    end 

  end
  namespace :seed do
    task :load => :environment do 
      require 'active_record/fixtures'
      ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
      (ENV['FIXTURES'] ? ENV['FIXTURES'].split(/,/) : Dir.glob(File.join(RAILS_ROOT, 'seed',  '*.{yml,csv}'))).each do |fixture_file|
        Fixtures.create_fixtures('seed', File.basename(fixture_file, '.*'))
      end
    end
  end
end
