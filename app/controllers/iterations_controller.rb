class IterationsController < ApplicationController
  before_filter :requires_login
  def index
    @iterations=Iteration.find(:all)
  end
end
