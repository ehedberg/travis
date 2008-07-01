class ReleasesController < ApplicationController
  helper Ziya::Helper
  before_filter :requires_login
  
  def index
    @releases = Release.paginate(:page=>params[:page], :order=>'created_at asc')
  end
  def create
    @release=Release.new(params[:release])

    if @release.save
      redirect_to(releases_path)
    else
      render :template=>"releases/form"
    end
  end
  
  def destroy
    Release.delete(params[:id])

    redirect_to(releases_path)
  end
  
  def show
    @release = Release.find(params[:id])
  end
 
  def new
    @release = Release.new

    render :template=>"releases/form"
  end

  def edit
    @release=Release.find(params[:id])
    render :template=>"releases/form"
  end

  def update
    @release= Release.find(params[:id])

    if @release.update_attributes(params[:release])
      redirect_to(releases_path)
    else
      render :template=>"releases/form"
    end
  end
  def chart
    rel = Release.find(params[:id], :include=>[:iterations=>[:stories=>:tasks]])
    total_points = rel.total_points
    chart = Ziya::Charts::Line.new(nil,  "release_chart")
    days = []
    points = []
    scope=[]
      iters = rel.iteration_ids.join(',')
    rel.total_days.times do |n| 
      d= (rel.start_date+n)
      days << d
      points << (Story.connection.select_value("select sum(swag) from stories where iteration_id in ("+iters+") and state='passed' and date(completed_at)=date('%s')"%d.to_s(:db))|| 0).to_f  if d <= Date.today 
      scope << (Story.connection.select_value("select sum(swag) from stories where iteration_id in ("+iters+") and  date(created_at)=date('%s') and iteration_id=%d"%[d.to_s(:db), rel.id])|| 0).to_f
    end
    point_totals  = []
    points.each{|x| point_totals<< (x+(point_totals.last||0.0))}
    scope_totals= []
    scope.each{|x| scope_totals << (x+(scope_totals.last||0.0))}
    #add swags from stories defined outside the iteration (but included in this iteration) to element 0
    outside_scope = rel.iterations.find(:all, :conditions=>['created_at < ? or created_at > ?', rel.start_date, rel.end_date]).map{|x|x.total_points}.compact.sum
    scope_totals = scope_totals.map{|x| x+outside_scope}

    strdays= days.map{|x| x.to_s(:db)}
    chart.add( :axis_category_text,  strdays)
    chart.add( :series, "Points complete", point_totals) unless point_totals.empty?
    chart.add( :series, "Scope", scope_totals)
    respond_to do |fmt| 
      fmt.xml { render :xml => chart.to_xml } 
    end 
  end

end
