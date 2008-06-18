class TasksController < ApplicationController
  before_filter :requires_login
  def index
    @tasks=Task.paginate :page=>params[:page], :order=>'created_at asc'
  end

  def show
    @task = Task.find(params[:id])
  end

  def new
    @task = Task.new
    render :template=>"tasks/form"
  end

  def search
    @saved_searches= SavedSearch.for_tasks
  end

  def do_search
    @tasks = Task.find(:all, :conditions=>params[:expr])
    @saved_search = SavedSearch.new(:query=>params[:expr], :query_type=>'Task')
    render :update do |page|
      unless @tasks.empty?
        page.replace_html 'results', :partial=>'tasks/task', :collection=>@tasks
        page.replace_html 'saveform', :partial=>'shared/save_search_form'
      else
        page.replace_html 'results', '<p>No results found</p>'
      end
    end
  end

  def create
    if params[:story_id]
      @task = Story.find(params[:story_id]).tasks.build(params[:task])
    else
      @task = Task.new(params[:task])
    end
    respond_to do |format|
      format.html { 
        if @task.save
          redirect_to tasks_path
        else
          render :template=>'tasks/form'
        end
      }

      format.js {
        if @task.save
          render :update do |page|
            page << "Control.Modal.close();"
            page.insert_html :bottom, 'tasks', :partial=>'stories/story_task', :object=>@task
          end
        else
          render :update do |page|
            page.replace('replaceable', :partial=>'stories/ajax_task', :locals=>{:task=>@task, :story_id=>params[:story_id]})
          end

        end
      }
    end
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
