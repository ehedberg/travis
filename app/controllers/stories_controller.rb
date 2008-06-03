class StoriesController < ApplicationController
  def index
    @stories=Story.find(:all)
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

    @story.save

    redirect_to(stories_path)
  end

  def update
    @story = Story.find(params[:id])

    @story.update_attributes(params[:story])

    redirect_to(stories_path)
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
