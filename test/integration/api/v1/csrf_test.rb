require "test_helper"

class ApiV1CsrfTest < ActionDispatch::IntegrationTest
  test "returns a CSRF token and starts a secure browser session" do
    get "/api/v1/auth/csrf"

    assert_response :ok

    body = response.parsed_body
    assert_predicate body.dig("data", "csrf_token"), :present?

    session_cookie = response.headers["Set-Cookie"]
    assert_includes session_cookie, "_eistatistik_session="
    assert_includes session_cookie, "httponly"
    assert_includes session_cookie, "samesite=lax"
    assert_equal "no-store", response.headers["Cache-Control"]
  end
end
