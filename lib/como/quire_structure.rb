module Como
  class QuireStructure
    attr_reader :quire
    attr_reader :errors

    def initialize quire
      @quire = quire
    end

    def build
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

      calculate_conjoins
      _structure
    end

    def add_slot subquire_num, quire_leaf
      _structure[subquire_num] ||= Subquire.new subquire_num
      return _structure if _structure[subquire_num].has_position? quire_leaf.position
      _structure[subquire_num] << QuireSlot.new(quire_leaf)
    end

    def structurally_valid?
      build
      @errors = []
      _structure.each do |sq|
        if sq.discontinuous?
          @errors << "Subquire #{sq.subquire_num} is discontinuous"
        end
        unless sq.even_bifolia?
          @errors << "Subquire #{sq.subquire_num} has an odd number of non-single leaves"
        end
      end

      return @errors.empty?
    end

    def top_level_quire
      build if _structure.blank?
      _structure.find { |sq| sq.main_quire? }
    end

    private
    def find_containment
      return if _structure.size < 2

      _structure.each do |outer|
        _structure.each do |inner|
          next if outer.equal? inner # don't compare same subquire
          outer.add_child inner if outer.immediate_parent? inner
        end
      end
    end

    def calculate_conjoins
      _structure.each &:calculate_conjoins
    end

    def _structure
      @structure ||= []
    end
  end
end