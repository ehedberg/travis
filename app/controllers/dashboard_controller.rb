class DashboardController < ApplicationController
  helper Ziya::Helper
  def index
    t = Date.today
    @iteration = Iteration.current
    if @iteration && Iteration.count  > 0
      @prediction= calculate_end_date(@iteration)
      all_iterations = Iteration.find(:all, :order=>'start_date asc')
      @next_iteration= all_iterations[all_iterations.index(@iteration)+1]
      @prev_iteration= all_iterations[all_iterations.index(@iteration)-1]
    else
      render :template=>'dashboard/empty'
    end
  end

  private
  def calculate_end_date(iter)
    raise "can't calculate on nil iteration?!" unless iter
    unpassed_points = Story.find(:all, :conditions=>"state != 'passed'", :select=>'swag').inject(0){|x,y| y.swag ? x+y.swag : 0 }.to_f
    iter.stories.find(:all, :conditions=>"state='passed'").each{|x| unpassed_points+=x.swag if x.swag.to_f}
    all_iters = Iteration.find(:all, :order=>'start_date asc')
    prev_iter = all_iters[all_iters.index(iter)-1]

    (iter.start_date + (unpassed_points/iter.velocity)*iter.total_days)
  end
end
