class Leaf < ActiveRecord::Base
  belongs_to :quire

  acts_as_list scope: :quire

  MODES = %w( original added replaced missing )

  def next
    lower_item
  end

  def previous
    higher_item
  end

  def description
    s = "Leaf "
    s += position.to_s
    if folio_number.present?
      s += " (fol/pg "
      s += folio_number
      s += ")"
    end
    s += " "
    s += mode
    s += "; "
    s += single? ? "single" : "conjoin"
  end

  def to_struct
    # create a struct of all non-nil values
    OpenStruct.new(to_hash.select { |k,v| !v.nil? })
  end

  def to_hash
    {
      n:            position,
      mode:         (mode || 'original'),
      single:       (single || false),
      folio_number: folio_number
    }
  end
end
