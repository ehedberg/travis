class TasksController < ApplicationController
  def index
    @tasks=Task.find(:all)
  end

  def show
    @task = Task.find(params[:id])
  end

  def new
    @task = Task.new
  end

  def create
    @task = Task.new(params[:task])
    @task.save
    redirect_to task_path(@task)
  end
end
