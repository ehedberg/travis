class BugsController < ApplicationController
  before_filter :login_required
  before_filter :find_bug, :except=>[:index, :new, :create]

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
    @bug.destroy
    redirect_to(bugs_path)
  end
  
  def update_swag
    b = @bug
    b.swag = params[:value].to_f
    b.save!
    render :text=>b.reload.swag
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
    @bug = Bug.find(params[:id])
  end
end
