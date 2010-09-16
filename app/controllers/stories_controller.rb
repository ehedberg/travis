class StoriesController < ApplicationController
  before_filter :login_required
  before_filter :load_parent
  def index
    if(params[:q])
      @stories = do_paginated_solr_search(params[:q], params[:page])
    else
      unless @iteration
        @stories=Story.paginate(:page=>params[:page], :order=>'created_at asc')
      else
        @stories = @iteration.stories.paginate :page=>params[:page], :order=>'created_at asc'
      end
    end
    respond_to do |wants|
      wants.html
      wants.csv do
        if request.env['HTTP_USER_AGENT'] =~ /msie/i
          headers['Pragma'] = 'public'
          headers['Content-type'] = 'text/plain'
          headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
          headers['Content-Disposition'] = "attachment; filename=\"#{csv_name}\""
          headers['Expires'] = '0'
        else
          headers["Content-Type"] ||= 'text/csv'
          headers["Content-Disposition"] = "attachment; filename=\"#{csv_name}\""
        end
        render :layout => false
      end
    end
  end
  

  def edit
    render :template=>"stories/form"
  end

  def search
    @saved_searches = SavedSearch.for_stories
  end

  def update_swag
    s = @story
    s.swag=params[:value].to_f
    s.save!
    render :text=>s.reload.swag
  end
  
  def update_tags
    s = @story
    s.tag_list=params[:value]
    s.save!
    render :text=>s.reload.tags.join(', ')
  end

  def do_search
    unless params[:tagsearch]
      @stories = Story.find(:all, :conditions=>params[:expr], :include=>:iteration)
      @saved_search = SavedSearch.new(:query=>params[:expr], :query_type=>'Story')
    else
      @stories = Story.find_tagged_with(params[:expr])
      @saved_search = SavedSearch.new(:query=>params[:expr], :query_type=>'Story')
    end
    render :update do |page|
      unless @stories.empty?
        page.replace_html 'results', :partial=>'stories/story_header'
        page.insert_html :bottom,  'results', :partial=>'stories/story', :collection=>@stories
        page.replace_html  'summary', "<p>#{@stories.size} stories</p>"
        page.replace_html 'saveform', :partial=>'shared/save_search_form'
        page.replace_html 'masstagform', :partial=>'stories/masstagform', :object=>@stories.map(&:id).join(',')
      else
        page.replace_html 'results', '<p>No results found</p>'
      end
    end
  end

  def mass_tag
    ids = params[:ids].split(',')
    s = Story.find(ids)
    tags = params[:tags].split(',')
    s.each do |x|
      x.tag_list.add tags
      x.save!
    end
    render :update do |page|
      page.visual_effect :toggle_appear, 'masstagform'
    end
  end

  def create
    @story=Story.new(params[:story])
    respond_to do |format|
      format.html {
        if @story.save
          redirect_to(story_path(@story))
        else
          render :template=>"stories/form"
        end
      }
      format.js {
        if @story.save
          render :update do |page|
            page << "Control.Modal.close();"
            page.insert_html :bottom,  'stories', :partial=>'stories/story', :object=>@story
          end
        else
          render :update do |page|
            page.replace 'replaceable', :partial=>'iterations/ajax_story', :locals=>{:story=>@story}
          end
        end
      }
    end
  end

  def update
    action = params[:story].delete(:state)
    if @story.update_attributes(params[:story])
      @story.send("#{action}!".to_sym) if action
      redirect_to story_path(@story)
    else
      render :template=>"stories/form"
    end
  end

  def new
    @story = Story.new

    render :template=>"stories/form"
  end

  def destroy
    iter = @story.iteration
    @story.destroy
    iter ? redirect_to(iteration_path(iter)) : redirect_to(stories_path)
  end

  def do_paginated_solr_search(query, page)
    page = page.nil? ? 1 : page.to_i
    offset = Story.per_page * (page - 1)
    WillPaginate::Collection.create(page, Story.per_page) do |pager|
      result = Story.find_by_solr(query, :offset => offset, :limit => Story.per_page, :order => "stories.created_at asc").results
      # inject the result array into the paginated collection:
      pager.replace(result)

      unless pager.total_entries
        # the pager didn't manage to guess the total count, do it manually
        pager.total_entries = Story.count_by_solr(query)
      end
    end
  end

  private
  def load_parent
    if params[:iteration_id]
      @iteration = Iteration.find(params[:iteration_id]) if params[:iteration_id]
      @story = @iteration.stories.find(params[:id]) if params[:id]
    else
      @story = Story.find(params[:id]) if params[:id]
    end
  end

  def csv_name
    if @iteration
      "stories-#{@iteration.id}-#{Time.now.strftime("%Y%m%d")}.csv"
    else
      "stories-#{Time.now.strftime("%Y%m%d")}.csv"
    end
  end
end
