module Como
  class QuireStructure
    attr_reader :quire
    attr_reader :errors

    def initialize quire
      @quire = quire
    end

    def structure
      _structure.dup
    end

    def size
      _structure.size
    end

    def build
      return structure if built?

      # add each quire_leaf to its subquire
      quire.quire_leaves.each do |quire_leaf|
        _add_quire_leaf quire_leaf.subquire, quire_leaf
        # quire0 is always in the first position
        _add_quire_leaf Subquire::MAIN_QUIRE_NUM, quire_leaf if quire_leaf.first?
        # quire0 is always in the last position
        _add_quire_leaf Subquire::MAIN_QUIRE_NUM, quire_leaf if quire_leaf.last?
      end

      find_containment
      calculate_conjoins

      structure
    end

    def structurally_valid?
      build unless built?
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
      build unless built?
      _structure.find { |sq| sq.main_quire? }
    end
    alias_method :top, :top_level_quire

    def subquire subquire_num
      _structure[subquire_num]
    end

    def built?
      !!@structure
    end

    def errors
      @errors.dup
    end

    private
    def _add_quire_leaf subquire_num, quire_leaf
      _structure[subquire_num] ||= Subquire.new subquire_num
      return _structure if _structure[subquire_num].has_quire_leaf? quire_leaf
      _structure[subquire_num].add_quire_leaf quire_leaf
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

    def calculate_conjoins
      _structure.each &:calculate_conjoins
    end

    def _structure
      @structure ||= []
    end
  end
end