class Ruhoh
  module Manager

    # OAuth2 for the API
    # Usage:
    #   class Api < Sinatra::Base
    #     register OAuth
    #     ...
    #   end
    module OAuth2

      # Name of the Mongo database
      DB = 'db'

      # -----------------------------------------------------------------------
      # OAuth2 Class Context
      # -----------------------------------------------------------------------

      class << self

        # Called when this extension is registered. Sets up oauth database
        # connection and authenticator.
        # @param [Sinatra::Base] app        sinatra application
        def registered(app)
          app.helpers Helpers
          oauth = app.oauth
          oauth.database = Mongo::Connection.new[DB]
          oauth.authenticator = lambda do |username, password|
            # TODO
            'x'
          end
          setup_routes app
        end

        # Installs a bunch of routes for granting/denying oauth.
        # @param [Sinatra::Base] app      sinatra application
        def setup_routes(app)
          oauth = app.oauth
          app.get '/oauth/authorize' do
            if current_user
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

        def current_user
          # TODO
          'x'
        end

      end

    end

  end
end
