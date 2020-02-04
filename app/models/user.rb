class User < ApplicationRecord
  devise :database_authenticatable, :rememberable, :trackable, :validatable

  belongs_to :hotel
end
