class Permission < ApplicationRecord
  has_many :role_permissions, dependent: :destroy, inverse_of: :permission
  has_many :roles, through: :role_permissions

  validates :key, :label, :category, presence: true
  validates :key, uniqueness: true
end
