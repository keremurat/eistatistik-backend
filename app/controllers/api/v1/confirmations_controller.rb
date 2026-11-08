module Api
  module V1
    class ConfirmationsController < ApplicationController
      before_action :prevent_caching

      def update
        user = User.confirm_by_token(params[:confirmation_token].to_s)

        return render_invalid_token if user.errors.any?

        render json: { data: { status: "confirmed" } }
      end

      private

      def render_invalid_token
        render json: {
          error: {
            code: "invalid_confirmation_token",
            message: "Confirmation link is invalid or expired"
          }
        }, status: :unprocessable_content
      end

      def prevent_caching
        response.headers["Cache-Control"] = "no-store"
      end
    end
  end
end
