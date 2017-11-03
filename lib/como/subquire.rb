module Como
   class Subquire
    MAIN_QUIRE_NUM = 0

    attr_reader :subquire_num
    attr_reader :quire

    def initialize quire, subquire_num
      @quire        = quire
      @subquire_num = subquire_num
      @substructure = []
    end

    def xml_id
      return quire.xml_id if top_level?
      "#{quire.xml_id}-#{subquire_num}"
    end

    def quire_number
      return quire.number if top_level?
      "#{quire.number}-#{subquire_num}"
    end

    def positions
      _slots.map(&:position).compact
    end

    def substructure_position slot
      _substructure.index(slot) + 1
    end

    def slot_position slot
      return unless has_slot? slot
      _slots.index(slot) + 1
    end

    ##
    # Return true if `slot` is in the list of slots, as opposed to its
    # substructure.
    #
    def has_slot? slot
      _slots.include? slot
    end

    def max_position
      positions.max
    end

    def min_position
      positions.min
    end

    def << quire_slot
      _slots << quire_slot
      # allow chaining of insertions
      self
    end

    def [] ndx
      _slots[ndx]
    end

    def add_quire_leaf quire_leaf
      return if has_quire_leaf? quire_leaf
      _slots << QuireSlot.new(quire_leaf)
      _add_quire_leaf_slot_to_substructure @slots.last
    end

    def has_quire_leaf? quire_leaf
      leaves.include? quire_leaf
    end

    def leaves
      _slots.flat_map { |slot| slot.quire_leaf || [] }
    end

    def has_position? position
      positions.include? position
    end

    def slots
      # don't allow direct access to @positions
      _slots.dup
    end

    def substructure
      _substructure.dup
    end

    def substructure_size
      _substructure.size
    end

    def empty?
      _slots.empty?
    end

    def contains? other
      return false unless other.is_a? self.class
      return false if empty? || other.empty?
      return min_position <= other.min_position &&
        other.max_position <= max_position
    end

    def main_quire?
      subquire_num == MAIN_QUIRE_NUM
    end

    def adjacent? other
      return false unless other.is_a? self.class
      return true  if main_quire? && other.min_position == min_position
      return true  if main_quire? && other.max_position == max_position
      return true  if positions.include?(other.min_position - 1)
      positions.include?(other.max_position + 1)
    end

    def immediate_parent? other
      contains?(other) && adjacent?(other)
    end

    def range
      return nil if empty?

      min_position..max_position
    end

    def add_child subquire
      (@children ||= Set.new) << subquire
      subquire._set_parent self
      self
    end

    def children
      (@children ||= Set.new).dup
    end

    def parent
      @parent
    end

    def top_level?
      parent.blank?
    end

    def has_parent?
      parent.present?
    end

    def empty?
      _slots.empty?
    end

    def size
      _slots.size
    end

    def non_singles
      _slots.reject &:single?
    end

    def even_bifolia?
      return non_singles.size.even?
    end

    def singles
      _slots.select &:single?
    end

    def unjoined_slots
      _slots.select &:unjoined?
    end

    def all_slots_joined?
      unjoined_slots.empty?
    end

    def slot_after slot
      ndx = _slots.index slot
      _slots[ndx + 1]
    end

    def slot_before slot
      ndx = _slots.index slot
      _slots[ndx - 1]
    end

    def middle? slot
      return false if size.even?
      _slots.index(slot) == (size / 2)
    end

    def before_middle? slot
      # If size is odd; middle index is size/2; before indices are less than
      # size/2. If even, size/2 is one past middle index.
      _slots.index(slot) < (size / 2)
    end

    def after_middle? slot
      # If size is odd; middle index is size/2; after indices are greater than
      # size/2.
      _slots.index(slot) > (size / 2) if middle? slot
      # If even, size/2 is one past middle index; after indices are greater
      # than or equal to size/2.
      _slots.index(slot) >= (size / 2)
    end

    ##
    # By definition a subquire cannot be discontinuous, if any of the parent
    # subquire's positions fall with in our range, something is off.
    #
    def discontinuous?
      return false if top_level?
      parent.slots.any? { |slot| range.include? slot.position }
    end

    def calculate_conjoins
      # don't calculate if structure doesn't make sense
      return if discontinuous?
      return unless even_bifolia?
      join_bifolia
      pair_up_singles
    end

    def join_bifolia
      bifolia = non_singles
      until bifolia.empty?
        left, right   = bifolia.shift, bifolia.pop
        left.conjoin  = right
        right.conjoin = left
      end
    end

    def pair_up_singles
      return if all_slots_joined?
      pair_single unjoined_slots.first
      # start over; positions have changed
      pair_up_singles
    end

    def pair_single slot
      case
      when slot == _slots.first
        new_slot = _new_conjoin slot
        _add_slot new_slot, after: _slots.last
      when slot == _slots.last
        new_slot = _new_conjoin slot
        _add_slot new_slot, before: _slots.first
      when middle?(slot)
        # if this slot is in the middle, the placeholder follows it
        new_slot = _new_conjoin slot
        _add_slot new_slot, after: slot
      when before_middle?(slot)
        new_slot = _new_conjoin slot
        # new_slot goes before previous slot's conjoin
        prev_slot = slot_before slot
        _add_slot new_slot, before: prev_slot.conjoin
      when after_middle?(slot)
        # new_slot goes after next slot's conjoin
        # if the next slot is unjoined, we have to wait to process this one
        return pair_single slot_after slot if slot_after(slot).unjoined?
        new_slot = _new_conjoin slot
        next_slot = slot_after slot
        _add_slot new_slot, after: next_slot.conjoin
      else
        raise "Shouldn't have a slot that doesn't match."
      end
    end

    def conjoin_map
      _slots.map { |slot| [slot_rep(slot), slot_rep(slot.conjoin)] }
    end

    def slot_rep slot
      { index: _slots.index(slot), position: slot.position }
    end

    def to_s
      "#{self.class.name}: subquire_num=#{quire_number}"
    end

    protected
    def _add_quire_leaf_slot_to_substructure quire_slot
      return if _substructure.include? quire_slot
      raise "Can't add placeholder slot as quire_leaf" if quire_slot.placeholder?
      raise "Can't add quire leaf to Subquire with placeholders" if _substructure.any?(&:placeholder?)
      _substructure << quire_slot
      _substructure.sort! { |a,b| a.position <=> b.position }
    end

    def _set_parent subquire
      @parent = subquire
      _fill_parent
    end

    def _fill_parent
      return if parent.nil?
      _substructure.each do |slot|
        parent._add_quire_leaf_slot_to_substructure slot
      end
      parent._fill_parent
    end

    ##
    # Add `quire_slot` to the main subquire structure before or after the slot
    # given as the `:before` or `:after` slot in `opts`. Either `:before` or
    # `:after` must be specified but not both. After adding the slot to the
    # top level structure, the slot is added to the substructure.
    def _add_slot quire_slot, opts={}
      ndx = _get_index _slots, opts
      _slots.insert ndx, quire_slot
      _add_slot_to_substructure quire_slot, opts
    end

    ##
    # Add `quire_slot` to the subquire substructure before or after the slot
    # given as the `:before` or `:after` slot in `opts`. Either `:before` or
    # `:after` must be specified but not both. After adding the slot to the
    # top level structure, the slot is added to the substructure.
    def _add_slot_to_substructure quire_slot, opts={}
      return if _substructure.include? quire_slot
      ndx = _get_index _substructure, opts
      _substructure.insert ndx, quire_slot
      parent._add_slot_to_substructure quire_slot, opts unless parent.nil?
    end

    private

    ##
    # Get the `:before` or `:after` index for the QuireSlot given as the
    # `:before` or `:after` value in `opts` index. This index will be used for
    # QuireSlot insertion; consequently, the `:before` index is the index of
    # the given slot, while the `:after` index is the index of the given slot
    # plus 1. Either `:before` or `:after` must be specified but not both.
    def _get_index sequence, opts
      _check_before_after_opts opts
      !!opts[:before] ? sequence.index(opts[:before]) : (sequence.index(opts[:after]) + 1)
    end

    ##
    # Confirm that opts has either `:before` or `:after` but not both and that
    # the given opt is a QuireSlot.
    def _check_before_after_opts opts={}
      unless (!!opts[:before]) ^ (!!opts[:after])
        msg = "opts must have :before or :after, but not both; got #{opts}"
        raise ArgumentError.new msg
      end
      slot = opts[:before] || opts[:after]
      unless slot.is_a? QuireSlot
        msg "`:before|:after` opt must be a QuireSlot: got #{slot}"
      end
    end

    def _new_conjoin slot
      new_slot         = QuireSlot.new
      slot.conjoin     = new_slot
      new_slot.conjoin = slot
      new_slot
    end

    def _slots
      (@slots ||= [])
    end

    def _substructure
      (@substructure ||= [])
    end
  end
end