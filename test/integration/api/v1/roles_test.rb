require "test_helper"

class ApiV1RolesTest < ActionDispatch::IntegrationTest
  setup do
    @password = "correct-horse"
    @admin = User.create!(
      email: "roles-admin@example.com",
      password: @password,
      confirmed_at: Time.current,
      role: "admin"
    )
    @customer = User.create!(
      email: "roles-customer@example.com",
      password: @password,
      confirmed_at: Time.current,
      role: "musteri"
    )
  end

  test "admin lists roles and a customer is forbidden" do
    get "/api/v1/roles", headers: auth_headers(@customer)

    assert_response :forbidden

    get "/api/v1/roles", headers: auth_headers(@admin)

    assert_response :ok
    keys = response.parsed_body.fetch("data").map { |role| role.fetch("key") }
    assert_includes keys, "admin"
    assert_includes keys, "musteri"
  end

  test "admin creates a role and the role can be updated without rewriting pages" do
    headers = auth_headers(@admin)

    post "/api/v1/roles",
      params: {
        role: {
          name: "Muhasebe",
          description: "Siparişleri görür",
          assignable: false,
          permissions: [ "siparis.listele", "menu.siparis" ]
        }
      },
      headers: headers,
      as: :json

    assert_response :created
    assert_equal "muhasebe", response.parsed_body.dig("data", "key")
    assert_equal "/admin", response.parsed_body.dig("data", "home_path")
    assert_equal [ "menu.siparis", "siparis.listele" ], response.parsed_body.dig("data", "permissions")

    patch "/api/v1/roles/muhasebe",
      params: { role: { name: "Muhasebe", description: "Sipariş ve takvim", assignable: true, permissions: [ "menu.takvim" ] } },
      headers: headers,
      as: :json

    assert_response :ok
    assert_equal [ "menu.takvim" ], response.parsed_body.dig("data", "permissions")
    assert_equal true, response.parsed_body.dig("data", "assignable")
  end

  private

  def auth_headers(user)
    cookies.to_hash.each_key { |key| cookies.delete(key) }
    csrf_token = fetch_csrf_token
    post "/api/v1/auth/login",
      params: { user: { email: user.email, password: @password, remember_me: false } },
      headers: { "X-CSRF-Token" => csrf_token },
      as: :json
    assert_response :ok
    { "X-CSRF-Token" => response.parsed_body.dig("data", "csrf_token") }
  end

  def fetch_csrf_token
    get "/api/v1/auth/csrf"
    response.parsed_body.dig("data", "csrf_token")
  end
end
