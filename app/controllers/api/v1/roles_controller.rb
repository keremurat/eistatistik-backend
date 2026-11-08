module Api
  module V1
    class RolesController < ApplicationController
      include Api::V1::RoleAuthorization

      def index
        roles = Role.includes(:permissions).order(:name)
        render json: { data: roles.map { |role| serialize_role(role) } }
      end

      def show
        render json: { data: serialize_role(find_role) }
      end

      def create
        role = Role.new(role_attributes)
        role.key = unique_key(role.name)
        role.system_role = false
        role.home_path = "/admin"

        Role.transaction do
          role.save!
          assign_permissions(role)
        end

        render json: { data: serialize_role(role) }, status: :created
      rescue ActiveRecord::RecordInvalid => error
        render_invalid(error.record)
      end

      def update
        role = find_role
        if role.key == "admin" && params.require(:role).key?(:permissions) && permission_keys.exclude?("diger.rol")
          return render json: {
            error: { code: "validation_failed", message: "Admin rolünden rol düzenleme yetkisi alınamaz" }
          }, status: :unprocessable_content
        end

        Role.transaction do
          role.update!(role_attributes)
          assign_permissions(role) if params.require(:role).key?(:permissions)
        end

        render json: { data: serialize_role(role.reload) }
      rescue ActiveRecord::RecordInvalid => error
        render_invalid(error.record)
      end

      private

      def find_role
        Role.includes(:permissions).find_by!(key: params[:key])
      end

      def role_attributes
        params.require(:role).permit(:name, :description, :assignable)
      end

      def permission_keys
        Array(params.require(:role)[:permissions]).map(&:to_s)
      end

      def assign_permissions(role)
        role.permissions = Permission.where(key: permission_keys)
      end

      def unique_key(name)
        base = name.to_s.parameterize(separator: "_").presence || "rol"
        key = base
        suffix = 2
        while Role.exists?(key: key)
          key = "#{base}_#{suffix}"
          suffix += 1
        end
        key
      end

      def serialize_role(role)
        {
          key: role.key,
          name: role.name,
          description: role.description,
          assignable: role.assignable,
          system: role.system_role,
          home_path: role.home_path,
          permissions: role.permissions.map(&:key).sort
        }
      end

      def render_invalid(record)
        render json: {
          error: {
            code: "validation_failed",
            message: record.errors.full_messages.to_sentence,
            fields: record.errors.to_hash
          }
        }, status: :unprocessable_content
      end
    end
  end
end