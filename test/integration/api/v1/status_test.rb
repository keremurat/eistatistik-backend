require "test_helper"

class ApiV1StatusTest < ActionDispatch::IntegrationTest
  test "returns the API service status" do
    get "/api/v1/status"

    assert_response :ok
    assert_equal(
      {
        "data" => {
          "service" => "eistatistik-backend",
          "status" => "ok"
        }
      },
      response.parsed_body
    )
  end
end
