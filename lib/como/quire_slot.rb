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

  def joined?
    !!conjoin
  end

  def unjoined?
    conjoin.nil?
  end

  def to_s
    "#{self.class}: position: #{position}; conjoin: #{conjoin.position}"
  end
end