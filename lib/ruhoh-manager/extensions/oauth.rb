class Ruhoh
  module Manager

    # OAuth2 for the API
    # Usage:
    #   class Api < Sinatra::Base
    #     register OAuth
    #     ...
    #   end
    module OAuth

      def protect(oauth)

        oauth.database = Mongo::Connection.new['db']
        oauth.authenticator = lambda do |username, password|
          true
        end

      end

    end

  end
end
