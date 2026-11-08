require "test_helper"

class ApiV1SessionsTest < ActionDispatch::IntegrationTest
  setup do
    @password = "correct-horse"
    @user = User.create!(
      email: "student@example.com",
      password: @password,
      confirmed_at: Time.current
    )
  end

  test "signs in a confirmed user and returns the current user" do
    old_csrf_token = fetch_csrf_token
    old_session_cookie = cookies["_eistatistik_session"]

    post_login(email: @user.email, password: @password, csrf_token: old_csrf_token)

    assert_response :ok
    assert_equal @user.id, response.parsed_body.dig("data", "user", "id")
    assert_equal @user.email, response.parsed_body.dig("data", "user", "email")
    assert_equal "musteri", response.parsed_body.dig("data", "user", "role")
    assert_includes response.parsed_body.dig("data", "user", "permissions"), "menu.siparis"
    assert_equal "/dashboard", response.parsed_body.dig("data", "user", "home_path")
    assert_nil response.parsed_body.dig("data", "user", "encrypted_password")

    new_csrf_token = response.parsed_body.dig("data", "csrf_token")
    assert_predicate new_csrf_token, :present?
    assert_not_equal old_session_cookie, cookies["_eistatistik_session"]

    get "/api/v1/auth/me"

    assert_response :ok
    assert_equal @user.id, response.parsed_body.dig("data", "user", "id")
  end

  test "returns the same generic error for invalid, unconfirmed, and locked accounts" do
    csrf_token = fetch_csrf_token

    post_login(email: @user.email, password: "wrong-password", csrf_token: csrf_token)

    assert_response :unauthorized
    wrong_password_error = response.parsed_body.fetch("error")

    unconfirmed_user = User.new(
      email: "unconfirmed@example.com",
      password: @password
    )
    unconfirmed_user.skip_confirmation_notification!
    unconfirmed_user.save!
    csrf_token = fetch_csrf_token

    post_login(email: unconfirmed_user.email, password: @password, csrf_token: csrf_token)

    assert_response :unauthorized
    assert_equal wrong_password_error, response.parsed_body.fetch("error")

    locked_user = User.create!(
      email: "locked@example.com",
      password: @password,
      confirmed_at: Time.current
    )
    locked_user.update_columns(locked_at: Time.current, failed_attempts: 10)
    csrf_token = fetch_csrf_token

    post_login(email: locked_user.email, password: @password, csrf_token: csrf_token)

    assert_response :unauthorized
    assert_equal wrong_password_error, response.parsed_body.fetch("error")
  end

  test "a new login replaces the previous session instead of keeping it" do
    other = User.create!(
      email: "other-student@example.com",
      password: @password,
      confirmed_at: Time.current
    )
    csrf_token = fetch_csrf_token
    post_login(email: @user.email, password: @password, csrf_token: csrf_token)
    assert_response :ok
    renewed = response.parsed_body.dig("data", "csrf_token")

    post_login(email: other.email, password: @password, csrf_token: renewed)

    assert_response :ok
    assert_equal other.email, response.parsed_body.dig("data", "user", "email")
    assert_equal "musteri", response.parsed_body.dig("data", "user", "role")
    assert_equal "/dashboard", response.parsed_body.dig("data", "user", "home_path")
  end

  test "records failed authentication attempts through Devise" do
    csrf_token = fetch_csrf_token

    post_login(email: @user.email, password: "wrong-password", csrf_token: csrf_token)

    assert_equal 1, @user.reload.failed_attempts
  end

  test "rejects the pre-login CSRF token after session renewal" do
    old_csrf_token = fetch_csrf_token
    post_login(email: @user.email, password: @password, csrf_token: old_csrf_token)
    assert_response :ok

    delete "/api/v1/auth/logout", headers: { "X-CSRF-Token" => old_csrf_token }, as: :json

    assert_response :unprocessable_content
    assert_equal "invalid_csrf_token", response.parsed_body.dig("error", "code")
  end

  test "signs out with the renewed CSRF token" do
    csrf_token = fetch_csrf_token
    post_login(email: @user.email, password: @password, csrf_token: csrf_token)
    renewed_csrf_token = response.parsed_body.dig("data", "csrf_token")

    delete "/api/v1/auth/logout", headers: { "X-CSRF-Token" => renewed_csrf_token }, as: :json

    assert_response :no_content

    get "/api/v1/auth/me"

    assert_response :unauthorized
    assert_equal "authentication_required", response.parsed_body.dig("error", "code")
  end

  test "uses Devise rememberable when remember me is requested" do
    csrf_token = fetch_csrf_token

    post_login(
      email: @user.email,
      password: @password,
      csrf_token: csrf_token,
      remember_me: true
    )

    assert_response :ok
    assert_predicate @user.reload.remember_created_at, :present?
    assert_predicate cookies["remember_user_token"], :present?
  end

  private

  def fetch_csrf_token
    get "/api/v1/auth/csrf"
    response.parsed_body.dig("data", "csrf_token")
  end

  def post_login(email:, password:, csrf_token:, remember_me: false)
    post "/api/v1/auth/login",
      params: { user: { email: email, password: password, remember_me: remember_me } },
      headers: { "X-CSRF-Token" => csrf_token },
      as: :json
  end
end
