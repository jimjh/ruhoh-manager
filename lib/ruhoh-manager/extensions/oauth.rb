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
          _setup_oauth app.oauth
          _setup_routes app
        end

        private

        # Configures oauth
        def _setup_oauth(oauth)
          oauth.authorize_path = "#{Manager::BASE_PATH}/oauth/authorize"
          oauth.authorization_types = 'code'
          oauth.database = Mongo::Connection.new[DB]
          oauth.authenticator = lambda do |username, password|
            # TODO
            'x'
          end
        end

        # Installs a bunch of routes for granting/denying oauth.
        # @param [Sinatra::Base] app      sinatra application
        def _setup_routes(app)
          _route_for_authorize app
          _route_for_grant app
          _route_for_deny app
        end

        # Route for authorize
        def _route_for_authorize(app)
          app.get '/oauth/authorize' do
            if current_user
              erb :'oauth/authorize'
            else
              redirect "/oauth/login?authorization=#{app.oauth.authorization}"
            end
          end
        end

        # Route for grant
        def _route_for_grant(app)
          app.post '/oauth/grant' do
            # TODO
            oauth.grant! 'x'
          end
        end

        # Route for deny
        def _route_for_deny(app)
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
