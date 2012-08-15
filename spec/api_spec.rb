require 'spec_helper'

class Ruhoh
  module Manager
    module ApiSpec

      describe 'Api' do

        include Rack::Test::Methods

        def app
          Api
        end

        context 'missing controller/action/mime type' do

          it 'should return a 404 for missing controller' do
            get '/settings/config', {}, {'HTTP_ACCEPT' => 'application/json'}
            last_response.should be_ok
            get '/blah/xyz', {} ,{'HTTP_ACCEPT' => 'application/json'}
            last_response.should be_not_found
          end

          it 'should return a 404 for missing action' do
            get '/settings/config', {}, {'HTTP_ACCEPT' => 'application/json'}
            last_response.should be_ok
            get '/settings/xyz', {} ,{'HTTP_ACCEPT' => 'application/json'}
            last_response.should be_not_found
          end

          it 'should return a 406 for missing mime type' do
            get '/settings/config', {}, {'HTTP_ACCEPT' => 'application/json'}
            last_response.should be_ok
            get '/settings/config'
            last_response.status.should == 406
          end

        end

      end

    end
  end
end
