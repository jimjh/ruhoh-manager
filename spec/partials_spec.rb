# encoding: utf-8
require 'spec_helper'

class Ruhoh
  module Manager
    module PartialsSpec

      describe 'Partials Controller' do

        include Rack::Test::Methods

        Names = OpenStruct.new(Ruhoh::Names)
        PARTIALS_DIR = File.join(TEMP_SITE_PATH, Names.partials)

        def app
          Api
        end

        context 'well-formed requests' do

          it 'should return partials as text' do
            f = File.join PARTIALS_DIR, 'hello_test.md'
            IO.write f, 'ただいま', :mode => 'wb+'
            get '/partials/hello_test.md'
            last_response.should be_ok
            last_response.content_type.should match %{^text/plain;charset=utf-8}
            last_response.body.force_encoding('utf-8').should == 'ただいま'
          end

          it 'should handle partials within directories' do
            f = File.join(PARTIALS_DIR, 'some', 'nested', 'structure', 'x.md')
            FileUtils.mkdir_p File.dirname(f)
            IO.write f, '«»≈≠Ωº', :mode => 'wb+'
            get '/partials/some/nested/structure/x.md'
            last_response.should be_ok
            last_response.content_type.should match %{^text/plain;charset=utf-8}
            last_response.body.force_encoding('utf-8').should == '«»≈≠Ωº'
          end

          it 'should write successfully and return a 200 if file exists' do
            target = File.join(PARTIALS_DIR, 'target.md')
            IO.write target, 'here is some english text', :mode => 'wb+'
            put '/partials/target.md', '柳暗花明又一村'
            last_response.should be_ok
            IO.read(target).should == '柳暗花明又一村'
          end

          it 'should write successfully and return a 201 if file was created' do
            target = File.join(PARTIALS_DIR, 'target.md')
            put '/partials/target.md', '山重水复疑无路'
            last_response.status.should == 201
            IO.read(target).should == '山重水复疑无路'
          end

          it 'should delete the specified page if it exists' do
            target = File.join(PARTIALS_DIR, 'target.md')
            IO.write target, 'hello there this is jim', :mode => 'wb+'
            File.file?(target).should be_true
            delete '/partials/target.md'
            last_response.should be_ok
            File.file?(target).should be_false
          end

          it 'should return the directory listing as JSON/YAML/text' do

            FileUtils.mkdir File.join(PARTIALS_DIR, 'test')

            # construct directory
            child_file = File.join(PARTIALS_DIR, 'test','partial.md')
            IO.write child_file, 'x', :mode => 'w+'
            File.file?(child_file).should be_true

            child_dir = File.join(PARTIALS_DIR, 'test', 'foldr')
            FileUtils.mkdir child_dir
            File.directory?(child_dir).should be_true

            # check with and without trailing slashes
            get '/partials/test'
            last_response.should be_ok
            last_response.content_type.should match %r{^application/json;charset=utf-8}

            get '/partials/test/'
            last_response.should be_ok
            last_response.content_type.should match %r{^application/json;charset=utf-8}

            listing = JSON.parse last_response.body
            listing.size.should == 2
            listing.sort_by! { |entry| entry['name'] }
            listing[0].should == {'name' => 'foldr', 'size' => 68,
                                  'type' => 'directory'}
            listing[1].should == {'name' => 'partial.md', 'size' => 1,
                                  'type' => 'file'}

            # check other formats
            get '/partials/', {}, {'HTTP_ACCEPT' => 'application/x-yaml'}
            last_response.should be_ok
            last_response.content_type.should match %r{^application/x-yaml;charset=utf-8}

            get '/partials/', {}, {'HTTP_ACCEPT' => 'text/plain'}
            last_response.should be_ok
            last_response.content_type.should match %r{^text/plain;charset=utf-8}

          end

        end

        context 'malformed requests' do
          it 'should return 403 if resource path is not under +partials+' do
            # TODO: both get and put
          end
        end

        context 'reading/writing to other files' do

          it 'should return a 404 if getting unknown resource' do
            get '/partials/xyz'
            last_response.should be_not_found
          end

          it 'should return a 409 if the target path is a directory' do
            target = File.join(PARTIALS_DIR, 'target')
            FileUtils.mkdir_p target
            put '/partials/target', 'some content'
            last_response.status.should == 409
          end

          it 'should return a 404 if deleting unknown page' do
            delete '/partials/x'
            last_response.status.should == 404
          end

          it 'should return 403 if deleting directory' do
            FileUtils.mkdir File.join(PARTIALS_DIR, 'x')
            delete '/partials/x'
            last_response.status.should == 403
          end

        end

      end

    end
  end
end
