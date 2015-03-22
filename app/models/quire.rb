class Quire < ActiveRecord::Base
  belongs_to :manuscript
  acts_as_list scope: :manuscript
end
