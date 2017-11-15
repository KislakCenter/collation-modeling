module Como
  class Substructure
    attr_reader :subquire

    def initialize subquire
      @subquire = subquire
      @_slots = []
    end

    def position slot
      _slots.index(slot) + 1
    end

    def slots
      _slots.dup
    end

    def size
      _slots.size
    end

    def include? quire_slot
      _slots.include? quire_slot
    end

    def add_quire_leaf_slot quire_slot
      return if include? quire_slot
      raise "Can't add placeholder slot as quire_leaf" if quire_slot.placeholder?
      raise "Can't add quire leaf to Subquire with placeholders" if has_placeholder?
      _slots << quire_slot
      _slots.sort! { |a, b| a.position <=> b.position }
    end

    def fill_parent substructure
      slots.each do |quire_slot|
        substructure.add_quire_leaf_slot quire_slot
      end
    end

    ##
    # Add `quire_slot` to the main subquire structure before or after the slot
    # given as the `:before` or `:after` slot in `opts`. Either `:before` or
    # `:after` must be specified but not both.
    def add_slot quire_slot, opts={}
      # TODO: Rename to add_placeholdor or add_false_leaf
      # TODO: Extract to module HasSlots
      return if _slots.include? quire_slot
      ndx = _get_index opts
      _slots.insert ndx, quire_slot
    end

    private

    attr_reader :_slots

    def has_placeholder?
      _slots.any? &:placeholder?
    end

    ##
    # Get the `:before` or `:after` index for the QuireSlot given as the
    # `:before` or `:after` value in `opts` index. This index will be used for
    # QuireSlot insertion; consequently, the `:before` index is the index of
    # the given slot, while the `:after` index is the index of the given slot
    # plus 1. Either `:before` or `:after` must be specified but not both.
    def _get_index opts
      # TODO: Extract to module HasSlots
      _check_before_after_opts opts
      puts opts.inspect
      puts _slots.inspect
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
  end
end