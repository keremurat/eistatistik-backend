module Api
  module V1
    module RoleAuthorization
      extend ActiveSupport::Concern

      included do
        before_action :require_current_user
        before_action :require_role_manager
      end

      private

      def require_current_user
        return if current_user

        render json: {
          error: {
            code: "authentication_required",
            message: "Authentication is required"
          }
        }, status: :unauthorized
      end

      def require_role_manager
        return if current_user.can?("diger.rol")

        render json: {
          error: {
            code: "forbidden",
            message: "Bu işlem için yetkiniz yok"
          }
        }, status: :forbidden
      end
    end
  end
end
