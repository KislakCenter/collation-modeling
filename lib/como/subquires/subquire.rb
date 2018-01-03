module Como
  module Subquires
    ##
    # Subquire represents the super- and substructures of a quire.
    #
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

      def add_quire_leaf quire_leaf
        quire_slot = QuireSlot.new quire_leaf
        super_structure.append quire_slot
        substructure.append quire_slot
      end

      def has_quire_leaf? quire_leaf
        super_structure.include? quire_leaf
      end

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

      def add_child subquire
        (@children ||= Set.new) << subquire
        subquire._set_parent self
        self
      end

      def top_level?
        parent.blank?
      end

      def has_parent?
        parent.present?
      end

      def even_bifolia?
        super_structure.non_singles.size.even?
      end

      ##
      # By definition a subquire cannot be discontinuous, if any of the parent
      # subquire's positions fall with in our range, the user's input is wrong.
      def discontinuous?
        return false if top_level?
        super_structure.contains_any? ancestor_positions
      end

      def ancestor_positions
        return [] if top_level?
        parent.super_structure.positions + parent.ancestor_positions
      end

      def calculate_conjoins
        # don't calculate if structure doesn't make sense
        return if discontinuous?
        return unless super_structure.even_bifolia?
        super_structure.join_bifolia
        pair_up_singles
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
            _insert_placeholder new_slot, after: last_slot
          when super_structure.last?(slot)
            new_slot = _new_conjoin slot
            first_slot = super_structure.slots.first
            _insert_placeholder new_slot, before: first_slot
          when super_structure.middle?(slot)
            # if this slot is in the middle, the placeholder follows it
            new_slot = _new_conjoin slot
            _insert_placeholder new_slot, after: slot
          when super_structure.before_middle?(slot)
            new_slot = _new_conjoin slot
            # new_slot goes before previous slot's conjoin
            prev_slot = super_structure.slot_before slot
            _insert_placeholder new_slot, before: prev_slot.conjoin
          when super_structure.after_middle?(slot)
            # new_slot goes after next slot's conjoin
            # if the next slot is unjoined, we have to wait to process this one
            next_slot = super_structure.slot_after(slot)
            return pair_single next_slot if next_slot.unjoined?
            new_slot = _new_conjoin slot
            _insert_placeholder new_slot, after: next_slot.conjoin
          else
            raise "Shouldn't have a slot that doesn't match."
        end
      end

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
      def _insert_placeholder quire_slot, opts={}
        super_structure.insert_placeholder quire_slot, opts
        substructure.insert_placeholder quire_slot, opts
      end

      private

      def _new_conjoin slot
        new_slot         = QuireSlot.new
        slot.conjoin     = new_slot
        new_slot.conjoin = slot
        new_slot
      end
    end
  end
end