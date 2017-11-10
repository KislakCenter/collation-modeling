module LetHelpers
  def build_quire_and_leaves leaf_count=8, *singles
    quire = FactoryGirl.create(:quire)
    leaf_count.times do |i|
      attrs = { folio_number: i+1 }
      if singles.include?(attrs[:folio_number])
        attrs[:single]                      = true
        attrs[:attachment_method]           = 'sewn'
        attrs[:attachment_method_certainty] = 1
      end
      quire.leaves.create attrs
    end
    quire
  end
end