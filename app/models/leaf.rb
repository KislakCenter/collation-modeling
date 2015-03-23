class Leaf < ActiveRecord::Base
  belongs_to :quire

  acts_as_list scope: :quire

  MODES = %w( original added replaced missing )
end
