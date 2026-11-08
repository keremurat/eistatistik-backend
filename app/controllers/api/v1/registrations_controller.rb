module Api
  module V1
    class RegistrationsController < ApplicationController
      before_action :prevent_caching

      def create
        return render_legal_acceptance_required unless legal_documents_accepted?

        user = build_user

        User.transaction do
          user.save!
          record_legal_acceptances!(user)
        end

        render json: {
          data: {
            user: { id: user.id, email: user.email },
            next_step: "confirmation_required"
          }
        }, status: :created
      rescue ActiveRecord::RecordInvalid => error
        render_validation_failed(error.record)
      end

      private

      def build_user
        User.new(authentication_params).tap do |user|
          user.build_profile(profile_params)
        end
      end

      def authentication_params
        params.require(:user).permit(:email, :password, :password_confirmation)
      end

      def profile_params
        params.require(:user).permit(:first_name, :last_name)
      end

      def legal_documents_accepted?
        agreements = params.require(:user).fetch(:agreements, {})

        agreements[:membership_terms] == true && agreements[:kvkk_notice] == true
      end

      def record_legal_acceptances!(user)
        accepted_at = Time.current

        LegalAcceptance::CURRENT_VERSIONS.each do |document_key, document_version|
          user.legal_acceptances.create!(
            document_key: document_key,
            document_version: document_version,
            accepted_at: accepted_at,
            ip_address: request.remote_ip,
            user_agent: request.user_agent&.first(512)
          )
        end
      end

      def render_legal_acceptance_required
        render json: {
          error: {
            code: "legal_acceptance_required",
            message: "Current membership terms and privacy notice must be accepted"
          }
        }, status: :unprocessable_content
      end

      def render_validation_failed(record)
        render json: {
          error: {
            code: "validation_failed",
            message: "Registration could not be completed",
            fields: record.errors.to_hash
          }
        }, status: :unprocessable_content
      end

      def prevent_caching
        response.headers["Cache-Control"] = "no-store"
      end
    end
  end
end
