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
          _setup_filters app
        end

        private

        # Configures oauth
        def _setup_oauth(oauth)
          oauth.authorize_path = "#{Manager::BASE_PATH}/oauth/authorize"
          oauth.access_token_path = "#{Manager::BASE_PATH}/oauth/access_token"
          oauth.authorization_types = %w{code}
          oauth.param_authentication = true
          oauth.database = Mongo::Connection.new[DB]
          oauth.authenticator = lambda do |username, password|
            # TODO
            'x'
          end
        end

        # Installs filter to protect paths.
        # @param [Sinatra::Base] app      sinatra application
        def _setup_filters(app)
          _protect app, :method => [:get, :head], :scope => 'read'
          _protect app, :method => [:put, :post, :delete], :scope => 'write'
        end

        # Protects app by setting up path filters (helper method for
        # {_setup_filters}.
        #
        # = Options
        # - +:scope+      - +"read"+, +"write"+, or both
        # - +:method+     - one of +:get :head :put :post :delete+
        #
        # @param [Hash] opts            options hash
        # @param [Sinatra::Base] app    sinatra application
        # @see #_setup_filters
        def _protect(app, opts)
          scope = opts[:scope]
          app.before '/:controller/?*', :method => opts[:method] do
            halt oauth.no_access! unless oauth.authenticated?
            halt oauth.no_scope! scope unless oauth.scope.include? scope
          end
        end

        # Installs a bunch of routes for granting/denying oauth.
        # @param [Sinatra::Base] app      sinatra application
        def _setup_routes(app)
          _route_for_authorize app
          _route_for_grant app
          _route_for_deny app
        end

        # Route for +/oauth/authorize+.
        def _route_for_authorize(app)
          app.get '/oauth/authorize' do
            if current_user
              erb :'oauth/authorize'
            else
              redirect "/oauth/login?authorization=#{oauth.authorization}"
            end
          end
        end

        # Route for +/oauth/grant+.
        def _route_for_grant(app)
          app.post '/oauth/grant' do
            # TODO
            oauth.grant! 'x'
          end
        end

        # Route for +/oauth/deny+.
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
