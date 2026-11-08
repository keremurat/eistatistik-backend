require "test_helper"

class ApiV1RegistrationsTest < ActionDispatch::IntegrationTest
  setup do
    ActionMailer::Base.deliveries.clear
  end

  test "creates an unconfirmed user, profile, legal audit records, and confirmation email" do
    csrf_token = fetch_csrf_token

    assert_difference({
      "User.count" => 1,
      "Profile.count" => 1,
      "LegalAcceptance.count" => 2
    }) do
      post_registration(csrf_token: csrf_token)
    end

    assert_response :created

    user = User.find_by!(email: "new.user@example.com")
    assert_not user.confirmed?
    assert_equal "Ada", user.profile.first_name
    assert_equal "Lovelace", user.profile.last_name
    assert_equal %w[kvkk_notice membership_terms], user.legal_acceptances.order(:document_key).pluck(:document_key)
    assert user.legal_acceptances.all? { |acceptance| acceptance.accepted_at.present? }
    assert_equal "127.0.0.1", user.legal_acceptances.first.ip_address.to_s

    assert_equal 1, ActionMailer::Base.deliveries.size
    confirmation_email = ActionMailer::Base.deliveries.last
    assert_equal [ user.email ], confirmation_email.to
    assert_includes confirmation_email.body.encoded, "http://localhost:3000/hesap-dogrulama?confirmation_token="

    assert_equal user.id, response.parsed_body.dig("data", "user", "id")
    assert_equal "confirmation_required", response.parsed_body.dig("data", "next_step")
  end

  test "rejects registration unless both legal documents are accepted" do
    csrf_token = fetch_csrf_token

    assert_no_difference [ "User.count", "Profile.count", "LegalAcceptance.count" ] do
      post_registration(
        csrf_token: csrf_token,
        agreements: { membership_terms: true, kvkk_notice: false }
      )
    end

    assert_response :unprocessable_content
    assert_equal "legal_acceptance_required", response.parsed_body.dig("error", "code")
  end

  test "rolls back the whole registration when profile data is invalid" do
    csrf_token = fetch_csrf_token

    assert_no_difference [ "User.count", "Profile.count", "LegalAcceptance.count" ] do
      post_registration(csrf_token: csrf_token, last_name: "")
    end

    assert_response :unprocessable_content
    assert_equal "validation_failed", response.parsed_body.dig("error", "code")
  end

  private

  def fetch_csrf_token
    get "/api/v1/auth/csrf"
    response.parsed_body.dig("data", "csrf_token")
  end

  def post_registration(
    csrf_token:,
    last_name: "Lovelace",
    agreements: { membership_terms: true, kvkk_notice: true }
  )
    post "/api/v1/auth/register",
      params: {
        user: {
          email: "new.user@example.com",
          password: "correct-horse",
          password_confirmation: "correct-horse",
          first_name: "Ada",
          last_name: last_name,
          agreements: agreements
        }
      },
      headers: {
        "X-CSRF-Token" => csrf_token,
        "User-Agent" => "Eistatistik Registration Test"
      },
      as: :json
  end
end
