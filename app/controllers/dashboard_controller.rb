class DashboardController < ApplicationController
  helper Ziya::Helper
  def index
    t = Date.today
    @iteration = Iteration.find(:first, :conditions=>['start_date <= ? and end_date >= ?', t,t])
    if @iteration && Iteration.count  > 0
      all_iterations = Iteration.find(:all, :order=>'start_date asc')
      @next_iteration= all_iterations[all_iterations.index(@iteration)+1]
      @prev_iteration= all_iterations[all_iterations.index(@iteration)-1]
    else
      render :template=>'dashboard/empty'
    end
  end
end
