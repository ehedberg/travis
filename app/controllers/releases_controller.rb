class ReleasesController < ApplicationController
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
    rel = Release.find(params[:id], :include=>[:iterations])
    total_points = rel.total_points
    chart = Ziya::Charts::Line.new 
    days = []
    points = []
    scope=[]
    rel.total_days.times do |n| 
      d= (rel.start_date+n)
      days << d
      iter_ids = rel.iteration.map(&:id).join(", ")
      points << (Story.connection.select_value("select sum(swag) from stories where iteration_id in ("+iter_ids+") and state='pass' and date(completed_at)=date('%s')"%d.to_s(:db))|| 0).to_f  if d <= Date.today 
      scope << (Story.connection.select_value("select sum(swag) from stories where  date(created_at)=date('%s') and iteration_id in ("+iter_ids+") "%[d.to_s(:db)])|| 0).to_f
    end
    z  = []
    points.each{|x| z<< (x+(z.last||0.0))}
    y= []
    #find stories on this iterawtion created before the start of the iteration.
    bstories = (Story.connection.select_value("select sum(swag) from stories where  date(created_at) < date('%s') and iteration_id in ("+iter_ids+") "%[rel.start_date.to_s(:db)])|| 0).to_f
    
#    bstories = iter.stories.find(:all, :conditions=>['created_at < ? or created_at > ?', iter.start_date, iter.end_date]).map{|x|x.swag}.compact
    y<< bstories.inject(0){|x,k|x+k}.to_i
    scope.each{|x| y << (x+(y.last||0.0))}

    strdays= days.map{|x| x.to_s(:db)}
    chart.add( :axis_category_text,  strdays)
    chart.add( :series, "Points complete", z) unless z.empty?
    chart.add( :series, "Scope", y)
    respond_to do |fmt| 
      fmt.xml { render :xml => chart.to_xml } 
    end 
  end

  
end
