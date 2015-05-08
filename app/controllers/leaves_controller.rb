class LeavesController < ApplicationController
  before_action :set_leaf, only: [:destroy ]

  def destroy
    @quire = @leaf.quire
    @leaf.destroy

    redirect_to quire_path(@quire)
  end

  private
  def set_leaf
    @leaf = Leaf.find(params[:id])
  end
end
