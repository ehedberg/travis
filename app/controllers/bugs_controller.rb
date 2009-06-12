class BugsController < ApplicationController
  before_filter :login_required
  before_filter :find_bug, :except=>[:index, :new, :create]

  def index
    @bugs = Bug.paginate :page=>params[:page]
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
    Bug.delete(@bug.id)
    redirect_to(bugs_path)
  end
  
  def update_swag
    b = @bug
    b.swag = params[:value].to_f
    b.save!
    render :text=>b.reload.swag
  end

  private
  def find_bug
    @bug = Bug.find(params[:id])
  end

end
