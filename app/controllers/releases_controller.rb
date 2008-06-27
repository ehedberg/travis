class ReleasesController < ApplicationController
  before_filter :requires_login
  
  def index
    @releases = Release.paginate(:page=>params[:page], :order=>'created_at asc')
  end
  def create
    @release=Release.new(params[:release])

    if @release.save
      redirect_to(releases_path)
    else
      render :template=>"releases/form"
    end
  end
  
  def destroy
    Release.delete(params[:id])

    redirect_to(releases_path)
  end
  
  def show
    @release = Release.find(params[:id])
  end
 
  def new
    @release = Release.new

    render :template=>"releases/form"
  end

  def edit
    @release=Release.find(params[:id])
    render :template=>"releases/form"
  end

  def update
    @release= Release.find(params[:id])

    if @release.update_attributes(params[:release])
      redirect_to(releases_path)
    else
      render :template=>"releases/form"
    end
  end

  
end
