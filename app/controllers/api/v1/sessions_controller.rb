module Api
  module V1
    class SessionsController < ApplicationController
      before_action :prevent_caching
      before_action :require_current_user, only: [ :show, :destroy ]

      def create
        request.env["devise.allow_params_authentication"] = true
        # Açık bir oturum yeni e-posta ve parolayı yok sayıp eski kullanıcıyı döndürür.
        if current_user
          sign_out(:user)
          warden.logout(:user)
        end
        user = warden.authenticate(scope: :user)

        return render_authentication_failed unless user

        sign_in(:user, user)

        render json: {
          data: {
            user: serialize_user(user),
            csrf_token: form_authenticity_token
          }
        }
      end

      def show
        render json: { data: { user: serialize_user(current_user) } }
      end

      def destroy
        sign_out(:user)
        head :no_content
      end

      private

      def prevent_caching
        response.headers["Cache-Control"] = "no-store"
      end

      def require_current_user
        return if current_user

        render json: {
          error: {
            code: "authentication_required",
            message: "Authentication is required"
          }
        }, status: :unauthorized
      end

      def render_authentication_failed
        # Prevent Warden's failure app from replacing this generic response
        # with account-state details such as "unconfirmed" or "locked".
        warden.custom_failure!

        render json: {
          error: {
            code: "invalid_credentials",
            message: "Email or password is invalid"
          }
        }, status: :unauthorized
      end

      def serialize_user(user)
        role = user.access_role
        {
          id: user.id,
          email: user.email,
          role: user.role,
          role_name: role&.name || user.role,
          home_path: role&.home_path || "/dashboard",
          permissions: user.permission_keys
        }
      end
    end
  end
end
