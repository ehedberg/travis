class DashboardController < ApplicationController
  helper Ziya::HtmlHelpers::Charts
  helper Ziya::YamlHelpers::Charts
  before_filter :requires_login
  def index
    t = Date.today
    @iteration = Iteration.current
    if @iteration && Iteration.count  > 0
      @prediction= @iteration.calculate_end_date
    else
      render :template=>'dashboard/empty'
    end
  end

  private
end
