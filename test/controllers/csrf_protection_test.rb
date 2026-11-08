require "test_helper"

class CsrfProtectedController < ApplicationController
  def token
    render json: { data: { csrf_token: form_authenticity_token } }
  end

  def create
    render json: { data: { accepted: true } }
  end
end

class CsrfProtectionTest < ActionController::TestCase
  tests CsrfProtectedController

  setup do
    @routes = ActionDispatch::Routing::RouteSet.new
    @routes.draw do
      get "token" => "csrf_protected#token"
      post "create" => "csrf_protected#create"
    end
    @previous_forgery_protection = CsrfProtectedController.allow_forgery_protection
    CsrfProtectedController.allow_forgery_protection = true
  end

  teardown do
    CsrfProtectedController.allow_forgery_protection = @previous_forgery_protection
  end

  test "rejects a state-changing request without a CSRF token" do
    post :create

    assert_response :unprocessable_content
    assert_equal "invalid_csrf_token", response.parsed_body.dig("error", "code")
  end

  test "accepts a state-changing request with the session CSRF token" do
    get :token
    csrf_token = response.parsed_body.dig("data", "csrf_token")

    @request.headers["X-CSRF-Token"] = csrf_token
    post :create

    assert_response :ok
    assert_equal true, response.parsed_body.dig("data", "accepted")
  end
end
