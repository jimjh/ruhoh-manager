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

          it 'should handle posts within directories' do
            f = File.join(POSTS_DIR, 'some', 'nested', 'structure', 'x.md')
            FileUtils.mkdir_p File.dirname(f)
            IO.write f, '«»≈≠Ωº', :mode => 'wb+'
            get '/posts/some/nested/structure/x.md'
            last_response.should be_ok
            last_response.content_type.should match %{^text/plain;charset=utf-8}
            last_response.body.force_encoding('utf-8').should == '«»≈≠Ωº'
          end

          it 'should write successfully and return a 200 if file exists' do
            target = File.join(POSTS_DIR, 'target.md')
            IO.write target, 'here is some english text', :mode => 'wb+'
            put '/posts/target.md', '柳暗花明又一村'
            last_response.should be_ok
            IO.read(target).should == '柳暗花明又一村'
          end

          it 'should write successfully and return a 201 if file was created' do
            target = File.join(POSTS_DIR, 'target.md')
            put '/posts/target.md', '山重水复疑无路'
            last_response.status.should == 201
            IO.read(target).should == '山重水复疑无路'
          end

          it 'should delete the specified post if it exists' do
            target = File.join(POSTS_DIR, 'target.md')
            IO.write target, 'hello there this is jim', :mode => 'wb+'
            File.file?(target).should be_true
            delete '/posts/target.md'
            last_response.should be_ok
            File.file?(target).should be_false
          end

        end

        context 'malformed requests' do
          it 'should return 403 if resource path is not under +posts+' do
            # TODO: both get and put
          end
        end

        context 'reading/writing to other files' do

          it 'should return a 404 if getting unknown resource' do
            get '/posts/xyz'
            last_response.should be_not_found
          end

          it 'should return a 409 if the target path is a directory' do
            target = File.join(POSTS_DIR, 'target')
            FileUtils.mkdir_p target
            put '/posts/target', 'some content'
            last_response.status.should == 409
          end

          it 'should return a 404 if deleting unknown post' do
            delete '/posts/x'
            last_response.status.should == 404
          end

          it 'should return 403 if deleting directory' do
            FileUtils.mkdir File.join(POSTS_DIR, 'x')
            delete '/posts/x'
            last_response.status.should == 403
          end

        end

      end

    end
  end
end
