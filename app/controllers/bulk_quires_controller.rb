class BulkQuiresController < ApplicationController
  before_action :set_manuscript, only: [ :create ]

  def create
    num_quires = quire_params[:number_of_quires].to_i
    num_leaves = quire_params[:leaves_per_quire].to_i

    num_quires.times do
      @manuscript.quires.build
      num_leaves.times do
        @manuscript.quires.last.leaves.build
      end
    end

    @manuscript.save!

    redirect_to @manuscript
  end

  private
  def set_manuscript
    @manuscript = Manuscript.find params[:manuscript_id]
  end

  def quire_params
    params.require(:manuscript).permit :leaf_count_input, :number_of_quires, :leaves_per_quire
  end
end
