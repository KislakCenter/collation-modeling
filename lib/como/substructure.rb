module Como
  class Substructure
    def initialize
      @_slots = []
    end

    def position slot
      @_slots.index(slot) + 1
    end

    def slots
      @_slots.dup
    end

    def size
      @_slots.size
    end

    def include? quire_slot
      @_slots.include? quire_slot
    end

    def add_quire_leaf quire_slot
      return if include? quire_slot
      raise "Can't add placeholder slot as quire_leaf" if quire_slot.placeholder?
      raise "Can't add quire leaf to Subquire with placeholders" if has_placeholder?
      _slots << quire_slot
      _slots.sort! { |a, b| a.position <=> b.position }
    end

    private

    attr_reader :_slots

    def has_placeholder?
      _slots.any? &:placeholder?
    end
  end
end