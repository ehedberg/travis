namespace :data do
  task :generate=>[:environment] do |t|
    Iteration.destroy_all
    Story.destroy_all
    Task.destroy_all
    Iteration.transaction do 
      20.times do |n|
        sdate = (n*14).days.from_now(4.weeks.ago)
        edate = 14.days.from_now(sdate)
        i= Iteration.create(:start_date=>sdate.to_s(:db), :end_date=>edate.to_s(:db), :title=>"Iteration #{n}")
        i.save!
        rand(20).times do |x|
          s = i.stories.create(:title=>"some story#{x}", :description=>"this is the description for task #{x}", :swag=>rand(20.0), :completed_at=>i.start_date+rand(14),:state=> "passed", :created_at=>(i.start_date+rand(3)))
          rand(10).times do |y|
            t = s.tasks.create(:title=>"task %d.%d.%d"%[n,x,y], :description=>'some description')
          end 
        end
      end
    end
    puts "created #{Story.count} stories with #{Task.count} tasks on #{Iteration.count} iterations."
  end
end
