class StoriesController < ApplicationController
  before_filter :requires_login
  def index
    @stories=Story.paginate(:page=>params[:page], :order=>'created_at asc')
  end

  def show
    @story= Story.find(params[:id])
  end

  def edit
    @story=Story.find(params[:id])
    render :template=>"stories/form"
  end

  def search
    @saved_searches = SavedSearch.for_stories
  end

  def update_swag
    s = Story.find(params[:id])
    s.swag=params[:value].to_f
    s.save!
    render :text=>s.reload.swag
  end

  def do_search
    @stories = Story.find(:all, :conditions=>params[:expr])
    @saved_search = SavedSearch.new(:query=>params[:expr], :query_type=>'Story')
    render :update do |page|
      unless @stories.empty?
        page.replace_html 'results', :partial=>'stories/story', :collection=>@stories
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
          redirect_to(stories_path)
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
    @story = Story.find(params[:id])
    if @story.update_attributes(params[:story])
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
    Story.delete(params[:id])

    redirect_to(stories_path)
  end
end
