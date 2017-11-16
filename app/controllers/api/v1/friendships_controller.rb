module Api
  module V1
    class FriendshipsController < ApplicationController
      include ZiCorners::INJECT['v1_friendship_service']

      def list
        render json: v1_friendship_service.friends_list(friends_list_params)
      end

      def connect
        render json: v1_friendship_service.friend_connection(friend_connection_params)
      end

      def unfriend
        render json: v1_friendship_service.unfriend_connection(friend_connection_params)
      end

      def common
        render json: v1_friendship_service.common_friend(common_friend_params)
      end

      private

      def friends_list_params
        params.permit(:email)
      end

      def friend_connection_params
        params.permit(friends: [])
      end

      def common_friend_params
        params.permit(friends: [])
      end

    end
  end
end
