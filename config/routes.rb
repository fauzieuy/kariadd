Rails.application.routes.draw do

  namespace :api, defaults: { format: :json } do
    namespace :v1 do

      resources :friendships, only: [] do
        collection do
          get 'list', action: :list
          post 'connect', action: :connect
          post 'unfriend', action: :unfriend
          get 'common', action: :common
        end
      end

      resources :subscribes, only: [] do
        collection do
          get 'subscription', action: :subscription
          post 'subscribe', action: :subscribe
          post 'unsubscribe', action: :unsubscribe
        end
      end

      resources :users, only: [:create] do
        collection do
          post 'block', action: :block
          post 'unblock', action: :unblock
          post 'send_text', action: :send_text
        end
      end

    end
  end
end
