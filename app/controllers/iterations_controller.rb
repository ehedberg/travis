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
end
