class Hotel < ApplicationRecord
  has_many :users, dependent: :restrict_with_error

  validates :external_id, presence: true, uniqueness: { case_sensitive: false }
  validates :name, presence: true
  validates :phone, presence: true, uniqueness: { case_sensitive: false }
end
