class QuireSlot
  attr_reader :position
  attr_reader :quire_leaf
  attr_accessor :conjoin

  def initialize quire_leaf
    @quire_leaf = quire_leaf
  end

  def single?
    @quire_leaf && @quire_leaf.single?
  end

  def position
    @quire_leaf && @quire_leaf.position
  end

  def joined?
    !!conjoin
  end

  def == other
    # using strict equivalence
    self == other.equal
  end
end