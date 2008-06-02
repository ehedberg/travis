class TasksController < ApplicationController
  def index
    @tasks=Task.find(:all)
  end

  def show
    @task = Task.find(params[:id])
  end
end
