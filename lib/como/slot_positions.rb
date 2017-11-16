module Como
  ##
  # This module provides methods for slot position queries and retrieval, and
  # supports the module Como::Slotted
  #
  module SlotPositions
    def first? slot
      _slots.first == slot
    end

    def last? slot
      _slots.last == slot
    end

    def after_middle? slot
      # If size is odd; middle index is size/2; after indices are greater than
      # size/2.
      _slots.index(slot) > (size / 2) if middle? slot
      # If even, size/2 is one past middle index; after indices are greater
      # than or equal to size/2.
      _slots.index(slot) >= (size / 2)
    end

    def before_middle? slot
      # If size is odd; middle index is size/2; before indices are less than
      # size/2. If even, size/2 is one past middle index.
      _slots.index(slot) < (size / 2)
    end

    def middle? slot
      return false if size.even?
      _slots.index(slot) == (size / 2)
    end

    def slot_before slot
      ndx = _slots.index slot
      _slots[ndx - 1]
    end

    def slot_after slot
      ndx = _slots.index slot
      _slots[ndx + 1]
    end
  end
end