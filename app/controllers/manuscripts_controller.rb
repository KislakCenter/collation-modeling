class ManuscriptsController < ApplicationController
  before_action :set_manuscript, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @manuscripts = Manuscript.all
    respond_with(@manuscripts)
  end

  def show
    respond_with(@manuscript)
  end

  def new
    @manuscript = Manuscript.new
    respond_with(@manuscript)
  end

  def edit
  end

  def create
    @manuscript = Manuscript.new(manuscript_params)
    @manuscript.save
    respond_with(@manuscript)
  end

  def update
    @manuscript.update(manuscript_params)
    respond_with(@manuscript)
  end

  def destroy
    @manuscript.destroy
    respond_with(@manuscript)
  end

  private
    def set_manuscript
      @manuscript = Manuscript.find(params[:id])
    end

    def manuscript_params
      params.require(:manuscript).permit(:title, :shelfmark, :url)
    end
end
