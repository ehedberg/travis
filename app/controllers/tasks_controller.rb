class TasksController < ApplicationController
  def index
    @tasks=Task.find(:all)
  end
end
