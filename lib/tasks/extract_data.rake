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
end
