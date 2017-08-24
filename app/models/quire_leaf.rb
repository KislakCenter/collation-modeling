class QuireLeaf < ActiveRecord::Base
  belongs_to :leaf
  belongs_to :quire

  validates :leaf, presence: true
  validates :quire, presence: true

  acts_as_list scope: :quire

  accepts_nested_attributes_for :leaf
end
