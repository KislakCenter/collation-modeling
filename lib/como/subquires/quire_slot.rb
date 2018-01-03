module Como
  module Subquires
    class QuireSlot
      attr_reader :position
      attr_reader :quire_leaf
      attr_accessor :conjoin

      def initialize quire_leaf=nil
        @quire_leaf = quire_leaf
      end

      def single?
        @quire_leaf && @quire_leaf.leaf_single?
      end

      def position
        @quire_leaf && @quire_leaf.position
      end

      def leaf
        return @quire_leaf.leaf if @quire_leaf
        @false_leaf ||= Leaf.new(mode: 'false')
      end

      def leaf_no
        @quire_leaf && @quire_leaf.position
      end

      def joined?
        !!conjoin
      end

      def unjoined?
        conjoin.nil?
      end

      def placeholder?
        @quire_leaf.nil?
      end

      def conjoin_position
        conjoin && conjoin.position
      end

      def to_s
        "#{self.class}: position: #{position}; conjoin: #{conjoin_position}"
      end
    end
  end
end