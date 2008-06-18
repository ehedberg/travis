class SavedSearchesController < ApplicationController

  def create
    @saved_search = SavedSearch.new(params[:saved_search])
    @saved_search.save
    redirect_on_type(@saved_search.query_type)
  end
  def destroy
    ss = SavedSearch.find(params[:id])
    SavedSearch.destroy(ss.id)
    redirect_on_type(ss.query_type)
  end
  private
  def redirect_on_type(query_type)
    redirect_to query_type == 'Story' ? search_stories_path : search_tasks_path
  end
end
