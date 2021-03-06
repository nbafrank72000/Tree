class Relation < ApplicationRecord
	belongs_to :owner, class_name: "User"
	belongs_to :owned, class_name: "Album"

	validates :owner_id, presence: true
	validates :owned_id, presence: true
end
