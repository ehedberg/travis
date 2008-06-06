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

  def create
    @story=Story.new(params[:story])

    if @story.save
      redirect_to(stories_path)
    else
      render :template=>"stories/form"
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
