class LegalAcceptance < ApplicationRecord
  CURRENT_VERSIONS = {
    "membership_terms" => "2026-11-04",
    "kvkk_notice" => "2026-11-04"
  }.freeze

  belongs_to :user, inverse_of: :legal_acceptances

  validates :document_key, inclusion: { in: CURRENT_VERSIONS.keys }
  validates :document_version, :accepted_at, presence: true
  validates :document_key, uniqueness: { scope: [ :user_id, :document_version ] }
end
