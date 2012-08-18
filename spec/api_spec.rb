require 'spec_helper'

class Ruhoh
  module Manager
    module ApiSpec

      describe 'Api' do

        include Rack::Test::Methods

        def app
          Api
        end

        context 'missing controller' do

          it 'should return a 404 for missing controller' do
            get '/settings/config', {}, {'HTTP_ACCEPT' => 'application/json'}
            last_response.should be_ok
            get '/blah/xyz', {} ,{'HTTP_ACCEPT' => 'application/json'}
            last_response.should be_not_found
            put '/settings/config', ""
            last_response.should be_ok
            put '/blah/xyz', ""
            last_response.should be_not_found
          end

          it 'should return a 404 for bad controller name' do
            get '/x.y/blah'
            last_response.should be_not_found
            put '/x.y/blah'
            last_response.should be_not_found
          end

        end

      end

    end
  end
end
