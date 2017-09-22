module Como
   class Subquire
    MAIN_QUIRE_NUM = 0

    attr_reader :subquire_num

    def initialize subquire_num
      @subquire_num = subquire_num
      @substructure = []
    end

    def positions
      _slots.map(&:position).compact
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

    def empty?
      @slots.nil? || @slots.empty?
    end

    def size
      return 0 if empty?
      @slots.size
    end

    def non_singles
      slots.reject &:single?
    end

    def even_bifolia?
      return non_singles.size.even?
    end

    def singles
      slots.select &:single?
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
      slots.each_with_index do |slot, ndx|
        next unless slot.unjoined?
        if slot == _slots.first
          new_slot         = QuireSlot.new
          slot.conjoin     = new_slot
          new_slot.conjoin = slot
          _add_slot new_slot, after: _slots.last
          return pair_up_singles
        end
        if slot == _slots.last
          new_slot         = QuireSlot.new
          slot.conjoin     = new_slot
          new_slot.conjoin = slot
          _add_slot new_slot, before: _slots.first
          return pair_up_singles
        end
      end
    end

    def to_s
      "#{self.class.name}: subquire_num=#{subquire_num}"
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

    def _slots
      (@slots ||= [])
    end

    def _substructure
      (@substructure ||= [])
    end
  end
end