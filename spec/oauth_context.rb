class Ruhoh
  module Manager

    # Test module for Ruhoh Manager.
    module Test

      # Shared context for examples that require OAuth.
      module OAuth

        CLIENT_ID = '000000000000000000000001'
        CLIENT_SECRET = 'theearthisround'
        REDIRECT_URI = 'http://test/callback'
        SCOPE = %w{read write}

        shared_context 'OAuth' do

          include Rack::Test::Methods

          before(:all) do
            _register_client
            @token = _access_token
          end

          alias :original_method_missing :method_missing
          def method_missing(sym, *args, &block)
            case sym
            when :oget, :oput, :odelete
              method = sym.to_s[1..-1].to_sym
              uri, params, headers = *args
              headers ||= {}
              # add oauth access token
              send method, uri, params, _oauth(headers), &block
            else
              original_method_missing sym, *args, &block
            end
          end

          private

          # Adds oauth access token to headers.
          # @param [Hash] headers     hash of headers
          def _oauth(headers)
            headers['HTTP_AUTHORIZATION'] = "OAuth #{@token}"
            headers
          end

          # Makes a POST request to retrieve the access token.
          # @return [String] access token
          def _access_token
            post "#{Manager::BASE_PATH}/oauth/access_token", \
              grant_type: 'password',
              client_id: CLIENT_ID,
              client_secret: CLIENT_SECRET,
              redirect_uri: REDIRECT_URI,
              scope: SCOPE,
              username: Manager.config.oauth['username'],
              password: Manager.config.oauth['password']
            last_response.should be_ok
            JSON.parse(last_response.body)['access_token']
          end

          # Registers an oauth2 client.
          def _register_client
            Rack::OAuth2::Server.options[:collection_prefix] = 'oauth2'
            Rack::OAuth2::Server.register \
              display_name: 'Test Client',
              link: 'http://test/',
              scope: SCOPE,
              redirect_uri: REDIRECT_URI,
              id: BSON::ObjectId.from_string(CLIENT_ID),
              secret: CLIENT_SECRET
          end

        end

      end # /OAuth

    end # /Test

  end
end
