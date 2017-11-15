module Como
  class SuperStructure
    include Como::Slotted

    attr_reader :subquire

    def initialize subquire
      @subquire     = subquire
      @slots        = []
    end

    def slot_rep slot
      {index: _slots.index(slot), position: slot.position}
    end

    ##
    # Add `quire_slot` to the main subquire structure before or after the slot
    # given as the `:before` or `:after` slot in `opts`. Either `:before` or
    # `:after` must be specified but not both.
    def add_slot quire_slot, opts={}
      # TODO: Extract to module HasSlots
      return if _slots.include? quire_slot
      ndx = _get_index opts
      _slots.insert ndx, quire_slot
    end

    def join_bifolia
      bifolia = non_singles
      until bifolia.empty?
        # TODO: change to left, right to leading, trailing
        left, right = bifolia.shift, bifolia.pop
        left.conjoin = right
        right.conjoin = left
      end
    end

    def contains_any? positions
      positions.any? { |posn|
        # binding.pry
        range.include? posn
      }
    end

    def after_middle? slot
      # If size is odd; middle index is size/2; after indices are greater than
      # size/2.
      _slots.index(slot) > (size / 2) if middle? slot
      # If even, size/2 is one past middle index; after indices are greater
      # than or equal to size/2.
      _slots.index(slot) >= (size / 2)
    end

    def before_middle? slot
      # If size is odd; middle index is size/2; before indices are less than
      # size/2. If even, size/2 is one past middle index.
      _slots.index(slot) < (size / 2)
    end

    def middle? slot
      return false if size.even?
      _slots.index(slot) == (size / 2)
    end

    def slot_before slot
      ndx = _slots.index slot
      _slots[ndx - 1]
    end

    def slot_after slot
      ndx = _slots.index slot
      _slots[ndx + 1]
    end

    def all_slots_joined?
      unjoined_slots.empty?
    end

    def unjoined_slots
      _slots.select &:unjoined?
    end

    def singles
      _slots.select &:single?
    end

    def even_bifolia?
      non_singles.size.even?
    end

    def non_singles
      _slots.reject &:single?
    end

    def range
      return nil if empty?

      min_position..max_position
    end

    def leaves
      _slots.flat_map {|slot| slot.quire_leaf || []}
    end

    def include? quire_leaf
      leaves.include? quire_leaf
    end

    def add_quire_leaf quire_leaf
      return if include? quire_leaf
      _slots << QuireSlot.new(quire_leaf)
    end

    def append quire_slot
      return if _slots.include? quire_slot
      _slots << quire_slot
    end

    def min_position
      positions.min
    end

    def max_position
      positions.max
    end

    ##
    # Return true if `slot` is in the list of slots, as opposed to its
    # substructure.
    #
    def has_slot? slot
      _slots.include? slot
    end

    def positions
      _slots.map(&:position).compact
    end

    def contains? super_struct
      return false if [self, super_struct].any? &:empty?
      return false unless min_position <= super_struct.min_position
      max_position >= super_struct.max_position
    end

    def adjacent? super_struct
      return false if empty? || super_struct.empty?
      return true  if shares_edge? super_struct
      # TODO: works only for contains adjacent; add contained_by adjacent
      return true if positions.include?(super_struct.min_position + 1)
      positions.include?(super_struct.max_position + 1)
    end

    def shares_edge? super_struct
      return true if super_struct.min_position == min_position
      super_struct.max_position == max_position
    end

    private

    def _new_conjoin slot
      new_slot = QuireSlot.new
      slot.conjoin = new_slot
      new_slot.conjoin = slot
      new_slot
    end


  end
end
