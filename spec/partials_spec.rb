# encoding: utf-8
require 'spec_helper'

class Ruhoh
  module Manager
    module PartialsSpec

      describe 'Partials Controller' do

        include_context 'OAuth'

        Names = OpenStruct.new(Ruhoh::Names)
        PARTIALS_DIR = File.join(TEMP_SITE_PATH, Names.partials)

        def app
          Api
        end

        context 'well-formed requests' do

          it 'should return partials as text' do
            f = File.join PARTIALS_DIR, 'hello_test.md'
            IO.write f, 'ただいま', :mode => 'wb+'
            oget '/partials/hello_test.md'
            last_response.should be_ok
            last_response.content_type.should match %{^text/plain;charset=utf-8}
            last_response.body.force_encoding('utf-8').should == 'ただいま'
          end

          it 'should handle partials within directories' do
            f = File.join(PARTIALS_DIR, 'some', 'nested', 'structure', 'x.md')
            FileUtils.mkdir_p File.dirname(f)
            IO.write f, '«»≈≠Ωº', :mode => 'wb+'
            oget '/partials/some/nested/structure/x.md'
            last_response.should be_ok
            last_response.content_type.should match %{^text/plain;charset=utf-8}
            last_response.body.force_encoding('utf-8').should == '«»≈≠Ωº'
          end

          it 'should write successfully and return a 200 if file exists' do
            target = File.join(PARTIALS_DIR, 'target.md')
            IO.write target, 'here is some english text', :mode => 'wb+'
            oput '/partials/target.md', '柳暗花明又一村'
            last_response.should be_ok
            IO.read(target).should == '柳暗花明又一村'
          end

          it 'should write successfully and return a 201 if file was created' do
            target = File.join(PARTIALS_DIR, 'target.md')
            oput '/partials/target.md', '山重水复疑无路'
            last_response.status.should == 201
            IO.read(target).should == '山重水复疑无路'
          end

          it 'should delete the specified page if it exists' do
            target = File.join(PARTIALS_DIR, 'target.md')
            IO.write target, 'hello there this is jim', :mode => 'wb+'
            File.file?(target).should be_true
            odelete '/partials/target.md'
            last_response.should be_ok
            File.file?(target).should be_false
          end

          # Prepares directory.
          def prep_dir
            FileUtils.mkdir File.join(PARTIALS_DIR, 'test')
            child_file = File.join(PARTIALS_DIR, 'test','partial.md')
            IO.write child_file, 'x', :mode => 'w+'
            File.file?(child_file).should be_true
            child_dir = File.join(PARTIALS_DIR, 'test', 'foldr')
            FileUtils.mkdir child_dir
            File.directory?(child_dir).should be_true
          end

          it 'should return the directory listing as JSON' do

            prep_dir

            # check with and without trailing slashes
            oget '/partials/test'
            last_response.should be_ok
            last_response.content_type.should match %r{^application/json;charset=utf-8}

            oget '/partials/test/'
            last_response.should be_ok
            last_response.content_type.should match %r{^application/json;charset=utf-8}

            listing = JSON.parse last_response.body
            listing.size.should == 2
            listing.sort_by! { |entry| entry['name'] }

            # delete size because dir size differs across OS
            listing[0].delete 'size'
            listing[0].sort.should == {'name' => 'foldr',
                                       'type' => 'directory'}.sort
            listing[1].sort.should == {'name' => 'partial.md',
                                       'size' => 1,
                                       'type' => 'file'}.sort

          end

          it 'should return the directory listing as YAML' do
            oget '/partials/', {}, {'HTTP_ACCEPT' => 'text/yaml'}
            last_response.should be_ok
            last_response.content_type.should match %r{^text/yaml;charset=utf-8}
          end

          it 'should return the directory listing as text' do
            oget '/partials/', {}, {'HTTP_ACCEPT' => 'text/plain'}
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
            oget '/partials/xyz'
            last_response.should be_not_found
          end

          it 'should return a 409 if the target path is a directory' do
            target = File.join(PARTIALS_DIR, 'target')
            FileUtils.mkdir_p target
            oput '/partials/target', 'some content'
            last_response.status.should == 409
          end

          it 'should return a 404 if deleting unknown page' do
            odelete '/partials/x'
            last_response.status.should == 404
          end

          it 'should return 403 if deleting directory' do
            FileUtils.mkdir File.join(PARTIALS_DIR, 'x')
            odelete '/partials/x'
            last_response.status.should == 403
          end

        end

      end

    end
  end
end
