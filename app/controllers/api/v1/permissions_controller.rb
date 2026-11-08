module Api
  module V1
    class PermissionsController < ApplicationController
      include Api::V1::RoleAuthorization

      def index
        permissions = Permission.order(:category, :label)
        render json: {
          data: permissions.map { |permission| serialize_permission(permission) }
        }
      end

      private

      def serialize_permission(permission)
        {
          key: permission.key,
          label: permission.label,
          category: permission.category
        }
      end
    end
  end
end
