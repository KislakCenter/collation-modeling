class QuireLeaf < ActiveRecord::Base
  belongs_to :leaf
  belongs_to :quire

  validates :leaf, presence: true
  validates :quire, presence: true
end
