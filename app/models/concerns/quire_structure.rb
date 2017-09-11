require 'active_support/concern'

module QuireStructure
  extend ActiveSupport::Concern

  def build_structure
    return _structure unless _structure.blank?

    # the first leaf and last leaves are always in subquire 0
    subquire0 = 0
    add_position subquire0, 0
    add_position subquire0, (self.quire_leaves.size - 1)

    quire_leaves.each_with_index do |quire_leaf, ndx|
      add_position quire_leaf.subquire, ndx
    end

    find_containment
  end

  def find_containment
    return if _structure.size < 2

    _structure.each do |outer|
      _structure.each do |inner|
        next if outer.equal? inner # don't compare same subquire
        outer.add_child inner if outer.contains? innner
      end
    end


  end

  def add_position subquire_num, position
    _structure[subquire_num] ||= Subquire.new subquire_num
    _structure[subquire_num] << position
  end

  private
  def _structure
    @structure ||= []
  end
end