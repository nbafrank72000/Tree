class Album < ApplicationRecord
  belongs_to :user
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true
  validates :name, presence: true, length: { maximum: 140 }
  validates :description, length: { maximum: 512 }

  has_many :photos, dependent: :destroy
  accepts_nested_attributes_for :photos

  has_many :owned_relations, class_name: "Relation", foreign_key: :owned_id
  has_many :owners, through: :owned_relations, source: :owner

  def post_to_past
  	update_attribute(:past, true)
  end

  def post_to_present
  	update_attribute(:past, false)
  end

  #--------------------------------------------------------------------------------------------
  def owned(someone)
    owners << someone
  end

  def unowned(someone)
    owners.default_scope(someone)
  end

  def owners?(someone)
    owners.include?(someone)
  end

end
