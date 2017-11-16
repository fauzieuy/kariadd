require 'dry-container'
require 'dry-auto_inject'

module ZiCorners
  class DIContainer
    extend Dry::Container::Mixin

    register 'v1_friendship_service' do
      V1::FriendshipService.new
    end

    register 'v1_subscribe_service' do
      V1::SubscribeService.new
    end

    register 'v1_user_service' do
      V1::UserService.new
    end

  end

  # dependency injection
  INJECT = Dry::AutoInject(ZiCorners::DIContainer)
end
