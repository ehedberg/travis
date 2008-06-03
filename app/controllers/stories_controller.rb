class StoriesController < ApplicationController
  def index
    @stories=Story.find(:all)
  end

  def edit
    @story=Story.find(params[:id])

    render :template=>"stories/form"
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
end
