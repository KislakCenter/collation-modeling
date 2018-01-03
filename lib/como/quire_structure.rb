module Como
  ##
  # Class to build and represent the structure of a quire based on user input.
  class QuireStructure
    attr_reader :quire
    attr_reader :errors

    def initialize quire
      @quire = quire
    end

    def subquires
      _subquires.dup
    end

    def size
      _subquires.size
    end

    def build
      return subquires if built?

      add_quire_leaves
      find_containment
      calculate_conjoins

      subquires
    end

    def add_quire_leaves
      # add each quire_leaf to its subquire
      first_ql = quire.quire_leaves.first
      last_ql = quire.quire_leaves.last
      quire.quire_leaves.each do |quire_leaf|
        if [first_ql, last_ql].include? quire_leaf
          # first and last quire leaf are always in main subquire
          _add_quire_leaf Subquires::Subquire::MAIN_QUIRE_NUM, quire_leaf
        end
        _add_quire_leaf quire_leaf.subquire, quire_leaf
      end
    end

    def structurally_valid?
      build unless built?
      @errors = []
      _subquires.each do |subquire|
        _check_continuity subquire
        _check_bifolia_even subquire
      end

      @errors.empty?
    end

    def top_level_quire
      build unless built?
      _subquires.find &:main_quire?
    end
    alias_method :top, :top_level_quire

    def subquire subquire_num
      _subquires[subquire_num]
    end

    def built?
      !_subquires.empty?
    end

    private

    def _check_continuity subquire
      return unless subquire.discontinuous?
      @errors << "Subquire #{subquire.subquire_num} is discontinuous"
    end

    def _check_bifolia_even subquire
      return if subquire.even_bifolia?
      msg = "Subquire #{subquire.subquire_num} " \
            'has an odd number of non-single leaves'
      @errors << msg
    end

    def _add_quire_leaf subquire_num, quire_leaf
      _subquires[subquire_num] ||= Subquires::Subquire.new @quire, subquire_num
      return _subquires if _subquires[subquire_num].has_quire_leaf? quire_leaf
      _subquires[subquire_num].add_quire_leaf quire_leaf
    end

    def find_containment
      return if _subquires.size < 2

      _subquires.each do |outer|
        _subquires.each do |inner|
          next if outer.equal? inner # don't compare same subquire
          outer.add_child inner if outer.immediate_parent? inner
        end
      end
    end

    def calculate_conjoins
      _subquires.each &:calculate_conjoins
    end

    def _subquires
      @subquires ||= []
    end
  end
end