class Role < ApplicationRecord
  has_many :role_permissions, dependent: :destroy, inverse_of: :role
  has_many :permissions, through: :role_permissions
  has_many :users, foreign_key: :role, primary_key: :key, inverse_of: :access_role, dependent: :restrict_with_exception

  validates :key, :name, :home_path, presence: true
  validates :key, uniqueness: true
  validates :key, format: { with: /\A[a-z0-9_]+\z/ }
end
