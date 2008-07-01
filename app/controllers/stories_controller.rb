class StoriesController < ApplicationController
  before_filter :requires_login
  before_filter :load_parent 
  def index
    @stories=Story.paginate(:page=>params[:page], :order=>'created_at asc')
  end

  def show
  end

  def edit
    render :template=>"stories/form"
  end

  def search
    @saved_searches = SavedSearch.for_stories
  end

  def update_swag
    s = @story
    s.swag=params[:value].to_f
    s.save!
    render :text=>s.reload.swag
  end

  def do_search
    @stories = Story.find(:all, :conditions=>params[:expr])
    @saved_search = SavedSearch.new(:query=>params[:expr], :query_type=>'Story')
    render :update do |page|
      unless @stories.empty?
        page.replace_html 'results', :partial=>'stories/story_header'
        page.insert_html :bottom,  'results', :partial=>'stories/story', :collection=>@stories
        page.replace_html 'saveform', :partial=>'shared/save_search_form'
      else
        page.replace_html 'results', '<p>No results found</p>'
      end
    end
  end

  def create
    @story=Story.new(params[:story])
    respond_to do |format|
      format.html {
        if @story.save
          redirect_to(story_path(@story))
        else
          render :template=>"stories/form"
        end
      }
      format.js {
        if @story.save
          render :update do |page|
            page << "Control.Modal.close();"
            page.insert_html :bottom,  'stories', :partial=>'stories/story', :object=>@story
          end
        else
          render :update do |page|
            page.replace 'replaceable', :partial=>'iterations/ajax_story', :locals=>{:story=>@story}
          end
        end
      }
    end
  end

  def update
    action = params[:story].delete(:state)
    if @story.update_attributes(params[:story])
      @story.send("#{action}!".to_sym) if action
      redirect_to(stories_path)
    else
      render :template=>"stories/form"
    end
  end

  def new
    @story = Story.new

    render :template=>"stories/form"
  end

  def destroy
    Story.delete(@story.id)
    redirect_to(stories_path)
  end
  private
  def load_parent
    if params[:iteration_id]
    @iteration = Iteration.find(params[:iteration_id]) if params[:iteration_id]
    @story = @iteration.stories.find(params[:id]) if params[:id]
    else
      @story = Story.find(params[:id]) if params[:id]
    end
  end
end
