# encoding: utf-8
require 'spec_helper'

class Ruhoh
  module Manager
    module PostsSpec

      describe 'Posts Controller' do

        include Rack::Test::Methods

        Names = OpenStruct.new(Ruhoh::Names)
        POSTS_DIR = File.join(TEMP_SITE_PATH, Names.posts)

        def app
          Api
        end

        context 'well-formed requests' do

          it 'should return posts as text' do
            f = File.join(POSTS_DIR, 'hello_test.md')
            IO.write f, 'ただいま', :mode => 'wb+'
            get '/posts/hello_test.md'
            last_response.should be_ok
            last_response.content_type.should match %{^text/plain;charset=utf-8}
            last_response.body.force_encoding('utf-8').should == 'ただいま'
          end

          it 'should handle nested posts' do
            f = File.join(POSTS_DIR, 'some', 'nested', 'structure', 'x.md')
            FileUtils.mkdir_p File.dirname(f)
            IO.write f, '«»≈≠Ωº', :mode => 'wb+'
            get '/posts/some/nested/structure/x.md'
            last_response.should be_ok
            last_response.content_type.should match %{^text/plain;charset=utf-8}
            last_response.body.force_encoding('utf-8').should == '«»≈≠Ωº'
          end

        end

        context 'malformed requests' do
          it 'should return 403 if resource path is not under +posts+' do
          end
        end

        context 'reading/writing to other files' do
          it 'should return a 404 if getting unknown resource' do
            get '/posts/xyz'
            last_response.should be_not_found
          end
        end

      end

    end
  end
end
