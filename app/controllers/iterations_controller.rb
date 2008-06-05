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

end
