class TasksController < ApplicationController
  before_filter :requires_login
  def index
    @tasks=Task.find(:all)
  end

  def show
    @task = Task.find(params[:id])
  end

  def new
    @task = Task.new
    render :template=>"tasks/form"
  end

  def create
    @task = Task.new(params[:task])
    @task.save
    redirect_to task_path(@task)
  end

  def edit
    @task = Task.find(params[:id])
    render :template=>"tasks/form"
  end

  def update
    @task = Task.find(params[:id])
    @task.update_attributes(params[:task])
    if !params[:task][:state].empty?
      action = params[:task][:state]
      @task.send action+"!"
      #if action == "start"
      #  @task.login = session[:login]
      #elsif action == "stop"
      #  @task.login = ""
      #end
      @task.save
    end
    redirect_to task_path(@task)
  end

  def destroy
    @task = Task.find(params[:id])
    @task.destroy
    redirect_to tasks_path
  end

end
