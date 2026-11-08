class RolePermission < ApplicationRecord
  belongs_to :role, inverse_of: :role_permissions
  belongs_to :permission, inverse_of: :role_permissions

  validates :permission_id, uniqueness: { scope: :role_id }
end
