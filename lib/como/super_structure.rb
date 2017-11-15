module Como
  class SuperStructure

    attr_reader :subquire

    def initialize subquire
      @subquire     = subquire
      @slots        = []
    end

    def slot_rep slot
      {index: _slots.index(slot), position: slot.position}
    end

    # def conjoin_map
    #   _slots.map {|slot| [slot_rep(slot), slot_rep(slot.conjoin)]}
    # end

    # def pair_single slot
    #   case
    #     when slot == _slots.first
    #       new_slot = _new_conjoin slot
    #       _add_slot new_slot, after: _slots.last
    #     when slot == _slots.last
    #       new_slot = _new_conjoin slot
    #       _add_slot new_slot, before: _slots.first
    #     when middle?(slot)
    #       # if this slot is in the middle, the placeholder follows it
    #       new_slot = _new_conjoin slot
    #       _add_slot new_slot, after: slot
    #     when before_middle?(slot)
    #       new_slot = _new_conjoin slot
    #       # new_slot goes before previous slot's conjoin
    #       prev_slot = slot_before slot
    #       _add_slot new_slot, before: prev_slot.conjoin
    #     when after_middle?(slot)
    #       # new_slot goes after next slot's conjoin
    #       # if the next slot is unjoined, we have to wait to process this one
    #       return pair_single slot_after slot if slot_after(slot).unjoined?
    #       new_slot = _new_conjoin slot
    #       next_slot = slot_after slot
    #       _add_slot new_slot, after: next_slot.conjoin
    #     else
    #       raise "Shouldn't have a slot that doesn't match."
    #   end
    # end

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



    def pair_up_singles
      return if all_slots_joined?
      pair_single unjoined_slots.first
      # start over; positions have changed
      pair_up_singles
    end

    def join_bifolia
      bifolia = non_singles
      until bifolia.empty?
        left, right = bifolia.shift, bifolia.pop
        left.conjoin = right
        right.conjoin = left
      end
    end

    # def calculate_conjoins
    #   # don't calculate if structure doesn't make sense
    #   return if discontinuous?
    #   return unless even_bifolia?
    #   join_bifolia
    #   pair_up_singles
    # end

    def contains_any? *positions
      positions.any? { |posn| range.include? posn }
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

    def size
      _slots.size
    end

    def empty?
      _slots.empty?
    end

    def range
      return nil if empty?

      min_position..max_position
    end

    def slots
      # don't allow direct access to @positions
      _slots.dup
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

    def min_position
      positions.min
    end

    def max_position
      positions.max
    end

    def [] ndx
      _slots[ndx]
    end

    def first? slot
      _slots.first == slot
    end

    def last? slot
      _slots.last == slot
    end

    ##
    # Return true if `slot` is in the list of slots, as opposed to its
    # substructure.
    #
    def has_slot? slot
      _slots.include? slot
    end

    def slot_position slot
      return unless has_slot? slot
      _slots.index(slot) + 1
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

    ##
    # Get the `:before` or `:after` index for the QuireSlot given as the
    # `:before` or `:after` value in `opts` index. This index will be used for
    # QuireSlot insertion; consequently, the `:before` index is the index of
    # the given slot, while the `:after` index is the index of the given slot
    # plus 1. Either `:before` or `:after` must be specified but not both.
    def _get_index opts
      # TODO: Extract to module HasSlots
      _check_before_after_opts opts
      !!opts[:before] ? _slots.index(opts[:before]) : (_slots.index(opts[:after]) + 1)
    end

    ##
    # Confirm that opts has either `:before` or `:after` but not both and that
    # the given opt is a QuireSlot.
    def _check_before_after_opts opts={}
      # TODO: Extract to module HasSlots
      unless (!!opts[:before]) ^ (!!opts[:after])
        msg = "opts must have :before or :after, but not both; got #{opts}"
        raise ArgumentError.new msg
      end
      slot = opts[:before] || opts[:after]
      unless slot.is_a? QuireSlot
        msg "`:before|:after` opt must be a QuireSlot: got #{slot}"
      end
    end

    def _slots
      (@slots ||= [])
    end

    def _new_conjoin slot
      new_slot = QuireSlot.new
      slot.conjoin = new_slot
      new_slot.conjoin = slot
      new_slot
    end


  end
end
