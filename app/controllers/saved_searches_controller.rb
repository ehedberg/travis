class SavedSearchesController < ApplicationController

  def create
    @saved_search = SavedSearch.new(params[:saved_search])
    if @saved_search.save
      render :update do |page|
        page.visual_effect :toggle_appear, 'saveform'
        page.insert_html :before, 'savedSearches',  :partial=>'shared/saved_search', :locals=>{:saved_search=>@saved_search}
        page.visual_effect :highlight, 'savedSearches'
      end
    else
      render :update do |page|
        page.replace_html 'saveform', :partial=>'shared/save_search_form'
      end
    end
  end
  def destroy
    ss = SavedSearch.find(params[:id])
    ss.destroy
    render :update do |page|
      page.visual_effect :toggle_slide, "saved_search_#{params[:id]}"
    end
  end
end
