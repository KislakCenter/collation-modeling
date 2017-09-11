class Subquire
  attr_reader :subquire_num

  def initialize subquire_num
    @subquire_num = subquire_num
  end

  def max_position
    positions.max
  end

  def min_position
    positions.min
  end

  def << position
    (@positions ||= Set.new) << position
    # allow chaining of insertions
    self
  end

  def positions
    # don't allow direct access to @positions
    (@positions ||= Set.new).dup
  end

  def empty?
    positions.empty?
  end

  def contains? other
    return false unless other.is_a? self.class
    return false if empty? || other.empty?
  end

  def range
    return nil if empty?

    (min_position..max_position)
  end

  def add_child wrapper
    (@children ||= Set.new) << wrapper
    wrapper._add_parent self
    self
  end

  def children
    (@children ||= Set.new).dup
  end

  def parents
    (@parents ||= Set.new).dup
  end

  def top_level?
    parents.empty?
  end

  def discontinuous?
    return false if top_level?
    parents.any? { |parent|
      parents.positions.any? { |posn|
        range.include? posn
      }
    }
  end

  def to_s
    "#{self.class.name}: quire_index=#{quire_index}"
  end

  protected

  def _add_parent wrapper
    (@parents ||= Set.new) << wrapper
    self
  end
end