module Como
  class Substructure
    include Como::Slotted

    attr_reader :subquire

    def initialize subquire
      @subquire = subquire
      @_slots = []
    end

    def append quire_slot
      return if _slots.include? quire_slot
      raise "Can't add placeholder slot as quire_leaf" if quire_slot.placeholder?
      raise "Can't add quire leaf to Subquire with placeholders" if has_placeholder?
      _slots << quire_slot
      _slots.sort! { |a, b| a.position <=> b.position }
    end

    def fill_parent substructure
      slots.each do |quire_slot|
        substructure.append quire_slot
      end
    end

    private

    def has_placeholder?
      _slots.any? &:placeholder?
    end

  end
end