module Api
  module V1
    class StatusController < ApplicationController
      def show
        render json: {
          data: {
            service: "eistatistik-backend",
            status: "ok"
          }
        }
      end
    end
  end
end
