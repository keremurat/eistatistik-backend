class Profile < ApplicationRecord
  belongs_to :user, inverse_of: :profile

  before_validation :normalize_names

  validates :first_name, :last_name, presence: true, length: { maximum: 100 }

  private

  def normalize_names
    self.first_name = first_name&.strip
    self.last_name = last_name&.strip
  end
end
