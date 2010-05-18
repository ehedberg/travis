class TasksController < ApplicationController
  before_filter :login_required
  before_filter :find_stories, :only => [:new, :edit] 
  def index
    @tasks=Task.paginate :page=>params[:page], :order=>'created_at asc'
  end

  def show
    @task = Task.find(params[:id])
  end

  def new
    find_stories
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
        page.replace_html 'results', :partial=>'task_headers'
        page.insert_html :bottom, 'results', :partial=>'tasks/task', :collection=>@tasks
        page.replace_html 'summary', "<p> #{@tasks.size} tasks.</p>"
        page.replace_html 'saveform', :partial=>'shared/save_search_form'
      else
        page.replace_html 'results', '<p>No results found</p>'
      end
    end
  end

  def create
    @task = Task.new(params[:task])
    respond_to do |format|
      format.html { 
        if @task.save
          Story.find(params[:story_id]).tasks << @task if params[:story_id]
          redirect_to tasks_path
        else
          find_stories
          render :template=>'tasks/form'
        end
      }

      format.js {
        if @task.save
          Story.find(params[:story_id]).tasks << @task if params[:story_id]
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
    find_stories
    @task = Task.find(params[:id])
    render :template=>"tasks/form"
  end

  def update
    @task = Task.find(params[:id])
    if @task.update_attributes(params[:task])
      if !params[:task][:state].empty?
        action = params[:task][:state]
        @task.send action+"!"
        @task.save
      end
      redirect_to task_path(@task)
    else
      find_stories
      render :template=>"tasks/form"
    end
  end

  def destroy
    @task = Task.find(params[:id])
    story = @task.stories ? @task.stories.first : nil
    @task.destroy
    story ? redirect_to(story_path(story)) : redirect_to(tasks_path)
  end

private
  def find_stories
    @stories = Story.find(:all, :conditions=>['state!=?','passed'], :order=>'mnemonic asc')
  end
end
