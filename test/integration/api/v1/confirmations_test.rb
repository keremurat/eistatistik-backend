require "test_helper"

class ApiV1ConfirmationsTest < ActionDispatch::IntegrationTest
  setup do
    ActionMailer::Base.deliveries.clear
  end

  test "confirms an account with the raw token from the email" do
    user = create_unconfirmed_user
    raw_token = confirmation_token_from_email
    csrf_token = fetch_csrf_token

    patch "/api/v1/auth/confirmation",
      params: { confirmation_token: raw_token },
      headers: { "X-CSRF-Token" => csrf_token },
      as: :json

    assert_response :ok
    assert user.reload.confirmed?
    assert_equal "confirmed", response.parsed_body.dig("data", "status")
  end

  test "returns a generic error for an invalid confirmation token" do
    csrf_token = fetch_csrf_token

    patch "/api/v1/auth/confirmation",
      params: { confirmation_token: "invalid-token" },
      headers: { "X-CSRF-Token" => csrf_token },
      as: :json

    assert_response :unprocessable_content
    assert_equal "invalid_confirmation_token", response.parsed_body.dig("error", "code")
  end

  test "rejects an expired confirmation token" do
    user = create_unconfirmed_user
    raw_token = confirmation_token_from_email
    user.update_column(:confirmation_sent_at, 4.days.ago)
    csrf_token = fetch_csrf_token

    patch "/api/v1/auth/confirmation",
      params: { confirmation_token: raw_token },
      headers: { "X-CSRF-Token" => csrf_token },
      as: :json

    assert_response :unprocessable_content
    assert_not user.reload.confirmed?
    assert_equal "invalid_confirmation_token", response.parsed_body.dig("error", "code")
  end

  private

  def create_unconfirmed_user
    User.create!(
      email: "confirm@example.com",
      password: "correct-horse",
      profile: Profile.new(first_name: "Ada", last_name: "Lovelace")
    )
  end

  def confirmation_token_from_email
    text = ActionMailer::Base.deliveries.last.text_part.body.decoded
    url = text[%r{http://localhost:3000/hesap-dogrulama\?confirmation_token=\S+}]
    URI.decode_www_form(URI.parse(url).query).to_h.fetch("confirmation_token")
  end

  def fetch_csrf_token
    get "/api/v1/auth/csrf"
    response.parsed_body.dig("data", "csrf_token")
  end
end
