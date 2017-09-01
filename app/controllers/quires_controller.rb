class QuiresController < ApplicationController
  before_action :set_quire, only: [ :show, :edit, :update, :destroy ]
  before_action :set_manuscript, only: [ :new, :create, :destroy ]

  respond_to :html

  def edit
  end

  def new
    @quire = @manuscript.quires.build
  end

  def create
    @quire = @manuscript.quires.build quire_params
    if @quire.save
      redirect_to @manuscript
    else
      render :new
    end
  end

  def show
  end

  def update
    if @quire.update(quire_params)
      redirect_to @quire.manuscript
    else
      render :edit
    end
  end

  def destroy
    @quire.destroy
    redirect_to @manuscript
  end

  private
  def set_quire
    @quire = Quire.find(params[:id])
  end

  def set_manuscript
    @manuscript = Manuscript.find params[:manuscript_id]
  end

  def quire_params
    params.require(:quire).permit(:preceding_folio_number,
      quire_leaves_attributes: [
        :mode,
        :_destroy,
        :id,
        leaf_attributes: [:id, :single, :folio_number]
      ]
    )
  end
end
