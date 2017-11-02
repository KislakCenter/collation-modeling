module LetHelpers
  def build_quire_and_leaves leaf_count=8, *singles
    quire = FactoryGirl.create(:quire)
    leaf_count.times do |i|
      attrs = { folio_number: i+1 }
      attrs[:single] = singles.include?(attrs[:folio_number])
      quire.leaves.create attrs
    end
    quire
  end
end