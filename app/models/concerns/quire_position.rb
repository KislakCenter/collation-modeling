class QuirePosition
  attr_reader :quire_leaf

  def initialize quire_leaf
    @quire_leaf = quire_leaf
  end

  def position
    @quire_leaf and @quire_leaf.position
  end

  def <=> other
    raise "Can't compare to #{other}" unless other.respond_to? :position
    position <=> other.position
  end

  def == other
    return false unless other.is_a? self.class
    return position == other.position
  end
end