class BulkQuiresController < ApplicationController
  before_action :set_manuscript, only: [ :create ]

  def create
    @manuscript.attributes = quire_params
    @manuscript.create_quires

    redirect_to @manuscript
  end

  private
  def set_manuscript
    @manuscript = Manuscript.find params[:manuscript_id]
  end

  def quire_params
    params.require(:manuscript).permit :quire_number_input, :leaves_per_quire_input
  end
end
