class Subquire
  MAIN_QUIRE_NUM = 1

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
    return min_position <= other.min_position && other.max_position <= max_position
  end

  def main_quire?
    subquire_num == MAIN_QUIRE_NUM
  end

  def adjacent? other
    return false unless other.is_a? self.class
    return true if main_quire? && other.min_position == min_position
    return true if main_quire? && other.max_position == max_position
    return true  if positions.include?(other.min_position - 1)
    positions.include?(other.max_position + 1)
  end

  def immediate_container? other
    contains? other && adjacent? other
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