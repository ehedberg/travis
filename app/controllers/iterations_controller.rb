class IterationsController < ApplicationController
  helper Ziya::Helper
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
    chart = Ziya::Charts::Bar.new 
    chart.add( :axis_category_text, %w[2006 2007 2008] ) 
    chart.add( :series, "Dogs", [10,20,30] ) 
    chart.add( :series, "Cats", [5,15,25] ) 
    respond_to do |fmt| 
      fmt.xml { render :xml => chart.to_xml } 
    end 
  end
end
