class ReleasesController < ApplicationController
  helper Ziya::HtmlHelpers::Charts
  helper Ziya::YamlHelpers::Charts
  before_filter :requires_login
  def index
    @releases = Release.paginate(:page=>params[:page], :include=>[:iterations], :order=>'iterations.start_date')
  end

  def planner
    @iterations = Iteration.find(:all, :order=>'start_date asc')
    @releases = Release.find(:all, :order=>'title asc')
  end
  def create
    @release=Release.new(params[:release])

    if @release.save
      redirect_to(releases_path)
    else
      find_iterations
      render :template=>"releases/form"
    end
  end

  def destroy
    @release = Release.find params[:id]
    @release.destroy
    redirect_to(releases_path)
  end

  def show
    @release = Release.find(params[:id])
  end

  def new
    @release = Release.new
    find_iterations
    render :template=>"releases/form"
  end

  def edit
    find_iterations
    @release=Release.find(params[:id])
    render :template=>"releases/form"
  end

  def do_assoc
    p "in do_assoc, params = #{params.inspect}"
    render :template=>'releases/planner'
  end

  def update
    @release= Release.find(params[:id])

    if @release.update_attributes(params[:release])
      redirect_to(releases_path)
    else
      find_iterations
      render :template=>"releases/form"
    end
  end

  def chart
    rel = Release.find(params[:id], :include=>{:iterations=>:stories})
    total_points = rel.total_points
    chart = Ziya::Charts::Line.new(nil,  "release_chart")
    days = []
    points = []
    scope=[]
    iters = rel.iteration_ids.join(',')
    rel.total_days.times do |n| 
      d= (rel.start_date+n)
      days << d
      points << rel.stories_passed_on(d) if d <= Date.today
      scope << rel.swags_created_on(d)

    end
    point_totals  = []
    points.each{|x| point_totals<< (x+(point_totals.last||0.0))}
    scope_totals= []
    scope.each{|x| scope_totals << (x+(scope_totals.last||0.0))}
    #add swags from stories defined outside the iteration (but included in this iteration) to element 0
    outside_scope = rel.total_points - scope.sum
    scope_totals = scope_totals.map{|x| x+outside_scope}

    strdays= days.map{|x| x.to_s(:db)}
    chart.add( :axis_category_text,  strdays)
    chart.add( :series, "Points complete", point_totals.empty? ? [0] : point_totals)
    chart.add( :series, "Scope", scope_totals)
    respond_to do |fmt| 
      fmt.xml { render :xml => chart.to_xml } 
    end 
  end

private
  def find_iterations
    @iterations = Iteration.find(:all, :order=>'start_date asc')
  end
end
