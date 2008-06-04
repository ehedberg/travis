class IterationsController < ApplicationController
  def index
    @iterations=Iteration.find(:all)
  end
end
