class ApplicationController < ActionController::API
  include ActionController::Cookies
  include ActionController::RequestForgeryProtection

  protect_from_forgery with: :exception, prepend: true

  rescue_from ActionController::InvalidAuthenticityToken do
    render json: {
      error: {
        code: "invalid_csrf_token",
        message: "CSRF token is missing or invalid"
      }
    }, status: :unprocessable_content
  end
end
