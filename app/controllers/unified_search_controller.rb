class UnifiedSearchController < ApplicationController
  before_filter :login_required

  def index
    p "******************** #{params.inspect} ************************"
    @bugs = BugsController.new.do_paginated_solr_search(params[:q], params[:page])
    @stories = StoriesController.new.do_paginated_solr_search(params[:q], params[:page])
    render :template=>'shared/unified_search_results'
  end
end
