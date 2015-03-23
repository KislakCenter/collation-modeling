class Quire < ActiveRecord::Base
  attr_accessor :leaf_count_input

  belongs_to :manuscript
  has_many :leaves, -> { order('position ASC') }
  accepts_nested_attributes_for :leaves

  before_save :create_leaves

  validate :must_have_even_bifolia

  acts_as_list scope: :manuscript

  def next
    lower_item
  end

  def previous
    higher_item
  end

  private

  def create_leaves
    if leaf_count_input && leaves.blank?
      leaf_count_input.to_i.times { |i| leaves.build }
    end
  end

  # Make sure that the number of leaves not marked 'single' is even.
  def must_have_even_bifolia
    count = leaves.where.not(single: true).count
    if count.odd?
      errors.add(:base, "The number of non-single leaves cannot be odd; found: #{count}")
    end
  end
end
