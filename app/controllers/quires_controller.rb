class QuiresController < ApplicationController
  before_action :set_quire, only: [:edit, :update ]

  respond_to :html

  def edit
  end

  def update
    if @quire.folios.present?
      @quire.update(quire_params)
      if @quire.next.present?
        redirect_to edit_quire_path(@quire.next)
      else
        redirect_to edit_manuscript_path(@quire.manuscript)
      end
    else
      @quire.update(quire_params)
      redirect_to edit_quire_path(@quire)
    end
  end

  private
  def set_quire
    @quire = Quire.find(params[:id])
  end

  def quire_params
    params.require(:quire).permit(:folio_count_input, :folios_attributes => [ :id, :mode, :single ])
  end
end
