class BugsController < ApplicationController
  before_filter :login_required
  before_filter :find_bug

  def index
    if(params[:q])
      @bugs = do_paginated_solr_search(params[:q], params[:page])
    else
      @bugs = Bug.paginate(:page=>params[:page], 
        :select=>'*, (case when severity is null then 999 else severity end) as severitysort, ' + 
                   ' (case when priority is null then 999 else priority end) as prioritysort', 
        :order=>'severitysort, prioritysort')
    end
  end
  
  def new
    @bug = Bug.new
    render :template=>'bugs/form'
  end

  def create
    @bug=Bug.new(params[:bug])
    if @bug.save
      redirect_to(bug_path(@bug))
    else
      render :template=>"bugs/form"
    end
  end

  def edit
    render :template=>"bugs/form"
  end

  def search
    @saved_searches = SavedSearch.for_bugs
  end

  def do_search
    unless params[:tagsearch]
      @bugs = Bug.find(:all, :conditions=>params[:expr], :include=>:iteration)
      @saved_search = SavedSearch.new(:query=>params[:expr], :query_type=>'Bug')
    else
      @bugs = Bug.find_tagged_with(params[:expr])
      @saved_search = SavedSearch.new(:query=>params[:expr], :query_type=>'Bug')
    end
    render :update do |page|
      unless @bugs.empty?
        page.replace_html 'results', :partial=>'bugs/bug_headers'
        page.insert_html :bottom,  'results', :partial=>'bugs/bug', :collection=>@bugs
        page.replace_html  'summary', "<p>#{@bugs.size} bugs</p>"
        page.replace_html 'saveform', :partial=>'shared/save_search_form'
        page.replace_html 'masstagform', :partial=>'bugs/masstagform', :object=>@bugs.map(&:id).join(',')
      else
        page.replace_html 'results', '<p>No results found</p>'
      end
    end
  end

  def mass_tag
    ids = params[:ids].split(',')
    b = Bug.find(ids)
    tags = params[:tags].split(',')
    b.each do |x|
      x.tag_list.add tags
      x.save!
    end
    render :update do |page|
      page.visual_effect :toggle_appear, 'masstagform'
    end
  end

  def update
    action = params[:bug].delete(:state)
    if @bug.update_attributes(params[:bug])
      @bug.send("#{action}!".to_sym) if !action.blank?
      redirect_to bug_path(@bug)
    else
      render :template=>"bugs/form"
    end
  end

  def show
  end

  def destroy
    iter = @bug.iteration
    @bug.destroy
    iter ? redirect_to(iteration_path(iter)) : redirect_to(bugs_path)
  end

  def update_swag
    b = @bug
    b.swag = params[:value].to_f
    b.save!
    render :text=>b.reload.swag
  end
  
  def update_tags
    @bug.tag_list=params[:value]
    @bug.save!
    render :text=>@bug.reload.tags.join(', ')
  end

  def do_paginated_solr_search(query, page)
    page = page.nil? ? 1 : page.to_i
    offset = Bug.per_page * (page - 1)
    WillPaginate::Collection.create(page, Bug.per_page) do |pager|
      result = Bug.find_by_solr(query, :offset => offset, :limit => Bug.per_page, :order => "bugs.severity asc, bugs.priority asc").results
      # inject the result array into the paginated collection:
      pager.replace(result)

      unless pager.total_entries
        # the pager didn't manage to guess the total count, do it manually
        pager.total_entries = Bug.count_by_solr(query)
      end
    end
  end

  private
  def find_bug
    @bug = Bug.find(params[:id]) if params[:id]
  end
end
