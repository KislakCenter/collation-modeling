class Manuscript < ActiveRecord::Base
  has_many :quires, -> { order('position ASC') }

  attr_accessor :quire_number_input

  before_create :build_quires

  private

  def build_quires
    quire_number_input and (1..quire_number_input.to_i).each do |i|
      quires.build number: i
    end
  end
end
