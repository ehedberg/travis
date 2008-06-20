class IterationsController < ApplicationController
  helper Ziya::Helper
  before_filter :requires_login, :except=>:chart
  def index

    @iterations = Iteration.paginate(:page=>params[:page], :order=>'created_at asc')
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

  def update
    @iteration= Iteration.find(params[:id])

    if @iteration.update_attributes(params[:iteration])
      redirect_to(iterations_path)
    else
      render :template=>"iterations/form"
    end
  end

  def create
    @iteration=Iteration.new(params[:iteration])

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
    points = []
    created=[]
    planned = []
    iter.total_days.times do |n| 
      planned << (total_points/iter.total_days+(planned.last||0))
      d= (iter.start_date+n)
      days << d
      if d <= Date.today
      points << (Story.connection.select_value("select sum(swag) from stories where state='pass' and completed_at='%s'"%d.to_s(:db))|| 0).to_f  unless d > Date.today
      end
      created << (Story.connection.select_value("select sum(swag) from stories where  created_at<'%s' and created_at > '%s'"%[d, iter.start_date])|| 0).to_f
    end
    z  = []
    points = points.each{|x| z<< x+(z.last||0)}
    
    strdays= days.map{|x| x.to_s(:db)}
    chart.add( :axis_category_text,  strdays)
    chart.add( :series, "Points complete", points)
    chart.add( :series, "Scope", created)
    chart.add( :series, "Planned", planned)
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
end
