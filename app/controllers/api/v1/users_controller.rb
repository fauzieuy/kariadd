module Api
  module V1
    class UsersController < ApplicationController
      include ZiCorners::INJECT['v1_user_service']

      def create
        render json: v1_user_service.new_user(user_params)
      end

      def block
        render json: v1_user_service.block(block_params)
      end

      def unblock
        render json: v1_user_service.unblock(block_params)
      end

      def send_text
        render json: v1_user_service.send_text(send_text_params)
      end

      private

      def user_params
        params.require(:user).permit(:email)
      end

      def block_params
        params.permit(:requestor, :target)
      end

      def send_text_params
        params.permit(:sender, :text)
      end

    end
  end
end
