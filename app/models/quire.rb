class Quire < ActiveRecord::Base
  attr_accessor :folio_count_input

  belongs_to :manuscript
  has_many :folios, -> { order('position ASC') }
  accepts_nested_attributes_for :folios

  before_save :create_folios

  validate :must_have_even_bifolia

  acts_as_list scope: :manuscript

  def next
    lower_item
  end

  def previous
    higher_item
  end

  private

  def create_folios
    if folio_count_input && folios.blank?
      folio_count_input.to_i.times { |i| folios.build }
    end
  end

  # Make sure that the number of folios not marked 'single' is even.
  def must_have_even_bifolia
    count = folios.where.not(single: true).count
    if count.odd?
      errors.add(:base, "The number of non-single folios cannot be odd; found: #{count}")
    end
  end
end
