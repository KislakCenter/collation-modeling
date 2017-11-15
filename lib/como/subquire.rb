module Como
   class Subquire
    MAIN_QUIRE_NUM = 0

    attr_reader :subquire_num
    attr_reader :quire
    attr_reader :super_structure
    attr_reader :substructure
    attr_reader :parent

    def initialize quire, subquire_num
      @quire        = quire
      @subquire_num = subquire_num
      @super_structure = SuperStructure.new self
      @substructure = Substructure.new self
    end

    def xml_id
      return quire.xml_id if top_level?
      "#{quire.xml_id}-#{subquire_num}"
    end

    def quire_number
      return quire.position if top_level?
      "#{quire.position}-#{subquire_num}"
    end

    # def max_position
    #   super_structure.max_position
    # end
    #
    # def min_position
    #   super_structure.min_position
    # end

    # def << quire_slot
    #   _slots << quire_slot
    #   # allow chaining of insertions
    #   self
    # end

    # def [] ndx
    #   _slots[ndx]
    # end

    def add_quire_leaf quire_leaf
      super_structure.add_quire_leaf quire_leaf
      substructure.add_quire_leaf_slot QuireSlot.new quire_leaf
    end

    def has_quire_leaf? quire_leaf
      super_structure.include? quire_leaf
    end

    # def slots
    #   # don't allow direct access to @positions
    #   _slots.dup
    # end

    # def substructure_size
    #   substructure.size
    # end

    def contains? other
      super_structure.contains? other.super_structure
    end

    def main_quire?
      subquire_num == MAIN_QUIRE_NUM
    end

    def adjacent? subquire
      super_structure.adjacent? subquire.super_structure
    end

    def immediate_parent? other
      return false unless contains? other
      adjacent?(other)
    end

    # def parent
    #   "x"
    # end

    # def range
    #   return nil if empty?
    #
    #   min_position..max_position
    # end

    def add_child subquire
      (@children ||= Set.new) << subquire
      subquire._set_parent self
      self
    end

    # def children
    #   (@children ||= Set.new).dup
    # end

    def top_level?
      parent.blank?
    end

    def has_parent?
      parent.present?
    end

    # def empty?
    #   _slots.empty?
    # end

    # def size
    #   _slots.size
    # end

    # def non_singles
    #   _slots.reject &:single?
    # end

    def even_bifolia?
      super_structure.non_singles.size.even?
    end

    # def singles
    #   _slots.select &:single?
    # end

    # def unjoined_slots
    #   _slots.select &:unjoined?
    # end

    # def all_slots_joined?
    #   unjoined_slots.empty?
    # end

    # def slot_after slot
    #   ndx = _slots.index slot
    #   _slots[ndx + 1]
    # end
    #
    # def slot_before slot
    #   ndx = _slots.index slot
    #   _slots[ndx - 1]
    # end

    # def middle? slot
    #   return false if size.even?
    #   _slots.index(slot) == (size / 2)
    # end

    # def before_middle? slot
    #   # If size is odd; middle index is size/2; before indices are less than
    #   # size/2. If even, size/2 is one past middle index.
    #   _slots.index(slot) < (size / 2)
    # end

    # def after_middle? slot
    #   # If size is odd; middle index is size/2; after indices are greater than
    #   # size/2.
    #   _slots.index(slot) > (size / 2) if middle? slot
    #   # If even, size/2 is one past middle index; after indices are greater
    #   # than or equal to size/2.
    #   _slots.index(slot) >= (size / 2)
    # end

    ##
    # By definition a subquire cannot be discontinuous, if any of the parent
    # subquire's positions fall with in our range, something is off.
    #
    def discontinuous?
      return false if top_level?
      # TODO: BUG: doesn't catch all ancestor positions
      super_structure.contains_any? parent.super_structure.positions
    end

    def calculate_conjoins
      # don't calculate if structure doesn't make sense
      return if discontinuous?
      return unless super_structure.even_bifolia?
      super_structure.join_bifolia
      pair_up_singles
    end

    def join_bifolia
      bifolia = super_structure.non_singles
      until bifolia.empty?
        left, right   = bifolia.shift, bifolia.pop
        left.conjoin  = right
        right.conjoin = left
      end
    end

    def pair_up_singles
      return if super_structure.all_slots_joined?
      pair_single super_structure.unjoined_slots.first
      # TODO: Refactor to avoid recursion
      # start over; positions have changed
      pair_up_singles
    end

    def pair_single slot
      case
      when super_structure.first?(slot)
        new_slot = _new_conjoin slot
        last_slot = super_structure.slots.last
        _add_slot new_slot, after: last_slot
      when super_structure.last?(slot)
        new_slot = _new_conjoin slot
        first_slot = super_structure.slots.first
        _add_slot new_slot, after: first_slot
      when super_structure.middle?(slot)
        # if this slot is in the middle, the placeholder follows it
        new_slot = _new_conjoin slot
        _add_slot new_slot, after: slot
      when super_structure.before_middle?(slot)
        new_slot = _new_conjoin slot
        # new_slot goes before previous slot's conjoin
        prev_slot = super_structure.slot_before slot
        _add_slot new_slot, before: prev_slot.conjoin
      when super_structure.after_middle?(slot)
        # new_slot goes after next slot's conjoin
        # if the next slot is unjoined, we have to wait to process this one
        next_slot = super_structure.slot_after(slot)
        return pair_single next_slot if next_slot.unjoined?
        new_slot = _new_conjoin slot
        _add_slot new_slot, after: next_slot.conjoin
      else
        raise "Shouldn't have a slot that doesn't match."
      end
    end

    # def conjoin_map
    #   _slots.map { |slot| [slot_rep(slot), slot_rep(slot.conjoin)] }
    # end

    # def slot_rep slot
    #   { index: _slots.index(slot), position: slot.position }
    # end

    def to_s
      "#{self.class.name}: subquire_num=#{quire_number}"
    end

    protected

    def _set_parent subquire
      @parent = subquire
      _fill_parent
    end

    def _fill_parent
      return if parent.nil?
      substructure.fill_parent parent.substructure
      parent._fill_parent
    end

    ##
    # Add `quire_slot` to the main subquire structure before or after the slot
    # given as the `:before` or `:after` slot in `opts`. Either `:before` or
    # `:after` must be specified but not both. After adding the slot to the
    # top level structure, the slot is added to the substructure.
    def _add_slot quire_slot, opts={}
      # TODO: Rename to add_place_holder or add_false_leaf
      super_structure.add_slot quire_slot, opts
      substructure.add_slot quire_slot, opts
      # _add_slot_to_substructure quire_slot, opts
    end

    private

    def _new_conjoin slot
      new_slot         = QuireSlot.new
      slot.conjoin     = new_slot
      new_slot.conjoin = slot
      new_slot
    end

    # def _slots
    #   (@slots ||= [])
    # end
    #
    # def _substructure
    #   (@substructure ||= [])
    # end
  end
end