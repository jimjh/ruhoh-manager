class Ruhoh
  module Manager

    # OAuth2 for the API
    # Usage:
    #   class Api < Sinatra::Base
    #     register OAuth2
    #     ...
    #   end
    module OAuth2

      # Name of the Mongo database
      DB = 'db'

      class << self

        # ---------------------------------------------------------------------
        # OAuth2 Class Context
        # ---------------------------------------------------------------------

        # Called when this extension is registered. Sets up oauth database
        # connection and authenticator.
        # @param [Sinatra::Base] app        sinatra application
        def registered(app)
          app.register Rack::OAuth2::Sinatra
          app.helpers Helpers
          setup_oauth app.oauth
          setup_routes app
        end

        # Configures oauth
        def setup_oauth(oauth)
          oauth.authorize_path = "#{Manager::BASE_PATH}/oauth/authorize"
          oauth.database = Mongo::Connection.new[DB]
          oauth.authenticator = lambda do |username, password|
            # TODO
            'x'
          end
        end

        # Installs a bunch of routes for granting/denying oauth.
        # @param [Sinatra::Base] app      sinatra application
        def setup_routes(app)
          oauth = app.oauth
          app.get '/oauth/authorize' do
            if current_user
              require 'pry'
              binding.pry
              erb :'oauth/authorize'
            else
              redirect "/oauth/login?authorization=#{oauth.authorization}"
            end
          end
          app.post '/oauth/grant' do
            # TODO
            oauth.grant! 'x'
          end
          app.post '/oauth/deny' do
            # TODO
            oauth.deny!
          end
        end

      end

      # Helper methods for request context
      module Helpers

        # ---------------------------------------------------------------------
        # OAuth2 Request Context
        # ---------------------------------------------------------------------

        # Gets the current user
        def current_user
          # TODO
          'x'
        end

      end

    end

  end
end
