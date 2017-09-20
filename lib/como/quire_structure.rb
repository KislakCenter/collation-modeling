require 'active_support/concern'

module Como
  class QuireStructure
    attr_reader :quire

    def initialize quire
      @quire = quire
    end

    def build_structure
      return _structure unless _structure.blank?

      # the first leaf and last leaves are always in subquire 0
      subquire0 = 0

      # add each quire_leaf to its subquire
      quire.quire_leaves.each do |quire_leaf|
        add_position quire_leaf.subquire, quire_leaf.position
        # quire0 is always in the first position
        add_position subquire0, quire_leaf.position if quire_leaf.first?
        # quire0 is always in the last position
        add_position subquire0, quire_leaf.position if quire_leaf.last?
      end

      find_containment
      _structure
    end

    def find_containment
      return if _structure.size < 2

      _structure.each do |outer|
        _structure.each do |inner|
          next if outer.equal? inner # don't compare same subquire
          outer.add_child inner if outer.immediate_parent? inner
        end
      end
    end

    def add_position subquire_num, position
      _structure[subquire_num] ||= Subquire.new subquire_num
      _structure[subquire_num] << position
    end

    def structurally_valid?
      build_structure
      @errors = []
      _structure.each do |sq|
        @errors << "Subquire #{sq} is discontinuous" if sq.discontinuous?
      end
      return @errors.blank?
    end

    private
    def _structure
      @structure ||= []
    end
  end
end