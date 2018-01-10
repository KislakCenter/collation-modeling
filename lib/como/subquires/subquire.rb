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
        contains?(other) && adjacent?(other)
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
        new_slot = _new_conjoin slot
        # DE 2017-12-10: New simpler, cleaner, more elegant algorithm
        #                proposed by Kate Lynch
        opts = if super_structure.first?(slot)
                 { after: super_structure.slots.last }
               else
                 # new_slot goes before previous slot's conjoin
                 prev_slot = super_structure.slot_before slot
                 { before: prev_slot.conjoin }
               end
        super_structure.insert_placeholder new_slot, opts
        _update_substructure new_slot, opts
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
      # Add `quire_slot` to the  substructure before or after the slot given
      # as the `:before` or `:after` slot in `opts`. If this Subquire has a
      # parent, invoke this method on the parent, and, thus, recurse up the
      # tree, updating each parent substructure.
      #
      # @param [QuireSlot] quire_slot
      # @param [Hash] opts
      def _update_substructure quire_slot, opts = {}
        substructure.insert_placeholder quire_slot, opts
        parent._update_substructure quire_slot, opts if has_parent?
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