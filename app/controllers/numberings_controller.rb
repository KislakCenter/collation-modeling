class NumberingsController < ApplicationController
  before_action :set_manuscript, only: [ :update ]
  before_action :set_leaf, only: [ :update ]

  def update
    @leaf.attributes = leaf_params
    @manuscript.renumber_from @leaf
    redirect_to @manuscript
  end

  private
  def set_manuscript
    @manuscript = Manuscript.find params[:manuscript_id]
  end

  def set_leaf
    @leaf = Leaf.find params[:id]
  end

  def leaf_params
    params.require(:leaf).permit :new_number
  end

end
