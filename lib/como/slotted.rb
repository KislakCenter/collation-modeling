module Como
  ##
  # Provide accessors and methods for managing QuireSlots
  module Slotted
    include SlotPositions

    def slot_position slot
      return unless has_slot? slot
      _slots.index(slot) + 1
    end

    def position slot
      _slots.index(slot) + 1
    end

    def slots
      # don't allow direct access to _slots
      _slots.dup
    end

    def [] ndx
      _slots[ndx]
    end

    def size
      _slots.size
    end

    def empty?
      _slots.empty?
    end

    ##
    # Insert single leaf's conjoin `quire_slot` to the main subquire structure
    # before or after the slot given as the `:before` or `:after` slot in
    # `opts`. Either `:before` or `:after` must be specified but not both.
    def insert_placeholder quire_slot, opts={}
      return if _slots.include? quire_slot
      ndx = _get_index opts
      _slots.insert ndx, quire_slot
    end

    protected

    def _slots
      (@slots ||= [])
    end

    ##
    # Get the `:before` or `:after` index for the QuireSlot given as the
    # `:before` or `:after` value in `opts` index. This index will be used for
    # QuireSlot insertion; consequently, the `:before` index is the index of
    # the given slot, while the `:after` index is the index of the given slot
    # plus 1. Either `:before` or `:after` must be specified but not both.
    def _get_index opts
      _check_before_after_opts opts
      !!opts[:before] ? _slots.index(opts[:before]) : (_slots.index(opts[:after]) + 1)
    end

    ##
    # Confirm that opts has either `:before` or `:after` but not both and that
    # the value is a QuireSlot.
    def _check_before_after_opts opts={}
      unless (!!opts[:before]) ^ (!!opts[:after])
        msg = "opts must have :before or :after, but not both; got #{opts}"
        raise ArgumentError, msg
      end
      slot = opts[:before] || opts[:after]
      unless slot.is_a? QuireSlot
        msg "`:before|:after` opt must be a QuireSlot: got #{slot}"
      end
    end
  end
end