class StoriesController < ApplicationController
  def index
    @stories=Story.find(:all)
  end

  def edit
    @story=Story.find(params[:id])
  end

  def update
    @story = Story.find(params[:id])

    @story.update_attributes(params[:story])

    redirect_to(stories_path)
  end
end
