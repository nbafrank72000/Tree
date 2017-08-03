class Album < ApplicationRecord
  belongs_to :user
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true
  validates :name, presence: true, length: { maximum: 140 }
  validates :description, length: { maximum: 512 }

  has_many :photos, dependent: :destroy
  accepts_nested_attributes_for :photos

  def post_to_past
  	update_attribute(:past, true)
  end

  def post_to_present
  	update_attribute(:past, false)
  end

end
