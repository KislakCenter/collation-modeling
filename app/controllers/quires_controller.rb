class QuiresController < ApplicationController
  before_action :set_quire, only: [:edit, :update ]

  respond_to :html

  def edit
  end

  def update
    if @quire.leaves.present?

      if @quire.update(quire_params)
        if @quire.next.present?
          redirect_to edit_quire_path(@quire.next)
        else
          redirect_to manuscript_path(@quire.manuscript)
        end
      else
        render action: :edit
      end
    else
      if @quire.update(quire_params)
        redirect_to edit_quire_path(@quire)
      else
        render action: :edit
      end
    end
  end

  private
  def set_quire
    @quire = Quire.find(params[:id])
  end

  def quire_params
    params.require(:quire).permit(:leaf_count_input, :leaves_attributes => [ :id, :mode, :single, :folio_number ])
  end
end
