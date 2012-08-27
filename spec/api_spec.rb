require 'spec_helper'

class Ruhoh
  module Manager
    module ApiSpec

      describe 'Api' do

        include_context 'OAuth'
        include_context 'Blog'

        def app
          Api
        end

        context 'missing controller' do

          it 'should return a 404 when getting with missing controller' do
            oget '/settings/config'
            last_response.should be_ok
            oget '/blah/xyz'
            last_response.should be_not_found
          end

          it 'should return a 404 when putting with missing controller' do
            oput '/settings/config', ''
            last_response.should be_ok
            oput '/blah/xyz', ''
            last_response.should be_not_found
          end

          it 'should return a 404 for bad controller name' do
            oget '/x.y/blah'
            last_response.should be_not_found
            oput '/x.y/blah'
            last_response.should be_not_found
          end

        end

      end

    end
  end
end
