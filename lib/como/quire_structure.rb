module Como
  class QuireStructure
    attr_reader :quire

    def initialize quire
      @quire = quire
    end

    def build_structure
      return _structure unless _structure.blank?

      # add each quire_leaf to its subquire
      quire.quire_leaves.each do |quire_leaf|
        add_slot quire_leaf.subquire, quire_leaf
        # quire0 is always in the first position
        add_slot Subquire::MAIN_QUIRE_NUM, quire_leaf if quire_leaf.first?
        # quire0 is always in the last position
        add_slot Subquire::MAIN_QUIRE_NUM, quire_leaf if quire_leaf.last?
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

    def add_slot subquire_num, quire_leaf
      _structure[subquire_num] ||= Subquire.new subquire_num
      return _structure if _structure[subquire_num].has_position? quire_leaf.position
      _structure[subquire_num] << QuireSlot.new(quire_leaf)
    end

    def structurally_valid?
      build_structure
      @errors = []
      _structure.each do |sq|
        @errors << "Subquire #{sq} is discontinuous" if sq.discontinuous?
      end
      return @errors.blank?
    end

    def top_level_quire
      build_structure if _structure.blank?
      _structure.find { |sq| sq.main_quire? }
    end

    private
    def _structure
      @structure ||= []
    end
  end
end