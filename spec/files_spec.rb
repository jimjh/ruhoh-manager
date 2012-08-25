require 'spec_helper'

class Ruhoh
  module Manager
    module FilesSpec

      # Tests generic functions shared across pages/posts/partials/media
      describe 'Files Controller' do

        include Rack::Test::Methods

        def app
          Api
        end

        it 'should deny access to hidden files' do
          api = mock app
          api.should_receive(:mime_type).and_return('application/json')
          api.should_receive(:halt).and_throw(:halt)
          controller = FilesController.new api
          expect {
            controller.send :_get, '.x', ['application/json']
          }.to throw_symbol :halt
        end

      end

    end
  end
end
