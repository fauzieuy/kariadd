module Api
  module V1
    class SubscribesController < ApplicationController
      include ZiCorners::INJECT['v1_subscribe_service']

      def subscription
        render json: v1_subscribe_service.subscriptions_list(subscriptions_list_params)
      end

      def subscribe
        render json: v1_subscribe_service.subscribe(subscribe_params)
      end

      def unsubscribe
        render json: v1_subscribe_service.unsubscribe(unsubscribe_params)
      end

      private

      def subscriptions_list_params
        params.permit(:email)
      end

      def subscribe_params
        params.permit(:requestor, :target)
      end

      def unsubscribe_params
        params.permit(:requestor, :target)
      end

    end
  end
end
