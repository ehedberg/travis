class IterationsController < ApplicationController
  helper Ziya::Helper
  before_filter :requires_login, :except=>:chart
  def index
    @iterations = Iteration.paginate(:page=>params[:page], :order=>'start_date  asc')
  end

  def show
    @iteration = Iteration.find(params[:id])
    respond_to do |wants|
      wants.html {
        render :html => @iteration
      }
      wants.json {
        render :json => @iteration.to_json(:include=>:stories);
      }
    end
  end

  def destroy
    @iteration = Iteration.find(params[:id])
    @iteration.destroy
    redirect_to(iterations_path)
  end

  def edit
    find_releases
    @iteration=Iteration.find(params[:id])
    render :template=>"iterations/form"
  end

  def new
    find_releases
    @iteration = Iteration.new
    render :template=>"iterations/form"
  end

  def update
    @iteration= Iteration.find(params[:id])
    if @iteration.update_attributes(params[:iteration])
      redirect_to(iterations_path)
    else
      find_releases
      render :template=>"iterations/form"
    end
  end

  def create
    @iteration=Iteration.new(params[:iteration])
    if @iteration.save
      redirect_to(iterations_path)
    else
      find_releases
      render :template=>"iterations/form"
    end
  end

  def chart
    iter = Iteration.find(params[:id], :include=>[:stories=>:tasks])
    total_points = iter.total_points
    chart = Ziya::Charts::Line.new(nil, "iteration_chart") 
    days = []
    points = []
    scope=[]
    iter.total_days.times do |n| 
      d= (iter.start_date+n)
      days << d
      points << iter.stories_bugs_passed_on(d)  if d <= Date.today 
      scope << iter.swags_created_on(d)
    end
    point_totals  = []
    points.each{|x| point_totals<< (x+(point_totals.last||0.0))}
    scope_totals= []
    scope.each{|x| scope_totals << (x+(scope_totals.last||0.0))}
    #add swags from stories defined outside the iteration (but included in this iteration) to element 0
    outside_scope = iter.total_points - scope.sum
    scope_totals = scope_totals.map{|x| x+outside_scope}

    strdays= days.map{|x| x.to_s(:db)}
    chart.add( :axis_category_text,  strdays)
    chart.add( :series, "Points complete", point_totals.empty? ? [0] : point_totals)
    chart.add( :series, "Scope", scope_totals)
    respond_to do |fmt| 
      fmt.xml { render :xml => chart.to_xml } 
    end 
  end


  def new_generate
  end

  def generate
    sdate = Date.parse(params[:start_date])
    edate = Date.parse(params[:end_date])
    span = (edate-sdate).numerator
    iter_size= params[:days].to_i
    numiter= ((span / params[:days].to_i).ceil).numerator

    Iteration.transaction do 
      numiter.times do |n|
        sd = sdate+(iter_size*n)
        Iteration.create!(:title=>"Iteration #{n+1}", :start_date=>sd.to_s(:db), :end_date=>(sd+(iter_size-1)).to_s(:db))
      end
    end
    redirect_to iterations_path
  end
  
  def reset_swags
    @iteration = Iteration.find_by_id(params[:id])
    if @iteration
      Iteration.transaction do
        @iteration.stories.each do |s|
          s.update_attributes(:swag=>nil) if s.state != 'passed'
        end
      end
      redirect_to iteration_path(@iteration) and return
    end
  end
  
  def promote_stories
    @iteration = Iteration.find_by_id(params[:id])
    if @iteration && @iteration.next
      Iteration.transaction do
        @iteration.stories.each do |s|
          s.update_attributes(:iteration_id=>@iteration.next.id) if s.state != 'passed'
        end
      end
      redirect_to iteration_path(@iteration) and return
    end
  end
private
  def find_releases
    @releases = Release.find(:all, :order=>'title asc')
  end
end
