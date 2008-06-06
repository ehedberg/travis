class DashboardController < ApplicationController
  helper Ziya::Helper
  def index
    t = Date.today
    @iteration = Iteration.find(:first, :conditions=>['start_date <= ? and end_date >= ?', t,t])
  end
end
