class User < ApplicationRecord
  has_one :profile, dependent: :destroy, inverse_of: :user, autosave: true
  has_many :legal_acceptances, dependent: :destroy, inverse_of: :user
  belongs_to :access_role, class_name: "Role", foreign_key: :role, primary_key: :key, optional: true, inverse_of: :users

  devise :database_authenticatable,
    :registerable,
    :recoverable,
    :rememberable,
    :validatable,
    :confirmable,
    :lockable,
    :timeoutable,
    :trackable

  validate :role_must_exist

  def permission_keys
    access_role&.permissions&.map(&:key) || []
  end

  def can?(key)
    permission_keys.include?(key)
  end

  private

  def role_must_exist
    return if role.blank?
    return unless Role.table_exists?
    return if Role.exists?(key: role)

    errors.add(:role, "tanımsız")
  end
end
