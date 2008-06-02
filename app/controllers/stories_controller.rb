class StoriesController < ApplicationController
  def index
    @stories=Story.find(:all)
  end
end
