module Api
  class HomesController < ApplicationController

    def index
      render json: {
        welcome: 'KariAdd is Friends Management',
        resource: 'https://github.com/fauzieuy/kariadd',
        email: 'me@mfauzi.id'
      }
    end

  end
end