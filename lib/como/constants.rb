module Como
  module Constants
    CERTAINTIES = [
      ['High',    1],
      ['Medium',  2],
      ['Low',     3]
    ].freeze

    CERTAINTY_NAMES_BY_CODE = CERTAINTIES.inject({}) { |memo, pair|
      memo.merge(pair.last => pair.first)
    }.freeze

  end
end