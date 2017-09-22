module Como
   class Subquire
    MAIN_QUIRE_NUM = 0

    attr_reader :subquire_num

    def initialize subquire_num
      @subquire_num = subquire_num
      @substructure = []
    end

    def positions
      (@slots ||= []).map(&:position).compact
    end

    def max_position
      positions.max
    end

    def min_position
      positions.min
    end

    def << quire_slot
      (@slots ||= []) << quire_slot
      # allow chaining of insertions
      self
    end

    def has_position? position
      positions.include? position
    end

    def slots
      # don't allow direct access to @positions
      (@slots ||= []).dup
    end

    def empty?
      @slots.nil? || @slots.empty?
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
        if slot == @slots.first
          new_slot = QuireSlot.new
          @slots.push new_slot
          slot.conjoin = new_slot
          new_slot.conjoin = slot
          return pair_up_singles
        end
        if slot == @slots.last
          new_slot = QuireSlot
          @slots.shift new_slot
          slot.conjoin = new_slot
          new_slot.conjoin = slot
          return pair_up_singles
        end
      end
    end

    def to_s
      "#{self.class.name}: subquire_num=#{subquire_num}"
    end

    protected
    def _set_parent subquire
      @parent = subquire
    end
  end
end