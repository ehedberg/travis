class IterationsController < ApplicationController
  before_filter :requires_login
  def index
    @iterations = Iteration.find(:all)
  end

  def show
    @iteration = Iteration.find(params[:id])
  end

  def destroy
    Iteration.delete(params[:id])

    redirect_to(iterations_path)
  end

  def edit
    @iteration=Iteration.find(params[:id])
    render :template=>"iterations/form"
  end

  def new
    @iteration = Iteration.new

    render :template=>"iterations/form"
  end

  def create
    @iteration=Iteration.new(params[:iteration])

    p @iteration.start_date

    if @iteration.save
      redirect_to(iterations_path)
    else
      render :template=>"iterations/form"
    end
  end

  def chart
    iter = Iteration.find(params[:id], :include=>[:stories=>:tasks])
    total_points = iter.total_points
    chart = Ziya::Charts::Line.new 
    days = []
    completed=[]
    points = []
    (iter.end_date - iter.start_date).numerator.times do |n| 
      d= (iter.start_date+n)
      days << d
      points << (Story.connection.select_value("select sum(swag) from stories where state='passed' and completed_at='%s'"%d)|| 0).to_f
    end
    z= []
    points.each do |p|
      z << (p+(z.last||0)) 

    end
    logger.debug "found points : #{points.inspect}"
    iter.start_date - iter.end_date
    strdays= days.map{|x| x.to_s(:db)}
    chart.add( :axis_category_text,  strdays)
    chart.add( :series, "Points complete", z)
    chart.add( :series, "Scope", [total_points]*14 ) 
    respond_to do |fmt| 
      fmt.xml { render :xml => chart.to_xml } 
    end 
  end
end
