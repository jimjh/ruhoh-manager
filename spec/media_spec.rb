# encoding: utf-8
require 'spec_helper'

class Ruhoh
  module Manager
    module MediaSpec

      describe 'Media Controller' do

        include_context 'OAuth'

        Names = OpenStruct.new(Ruhoh::Names)
        MEDIA_DIR = File.join(TEMP_SITE_PATH, Names.media)

        def app
          Api
        end

        context 'well-formed requests' do

          it 'should return media as jpg' do
            # content type shld be based on extension
            f = File.join MEDIA_DIR, 'hockey.jpg'
            IO.write f, 'ただいま', :mode => 'wb+'
            oget '/media/hockey.jpg'
            last_response.should be_ok
            last_response.content_type.should match %{^image/jpeg}
            last_response.content_length.should == File.new(f).size
          end

          it 'should handle media within directories' do
            f = File.join(MEDIA_DIR, 'some', 'nested', 'structure', 'x.png')
            FileUtils.mkdir_p File.dirname(f)
            IO.write f, '«»≈≠Ωº', :mode => 'wb+'
            oget '/media/some/nested/structure/x.png'
            last_response.should be_ok
            last_response.content_type.should match %{^image/png}
            last_response.content_length.should == File.new(f).size
          end

          it 'should write successfully and return a 200 if file exists' do
            target = File.join(MEDIA_DIR, 'target.md')
            IO.write target, 'here is some english text', :mode => 'wb+'
            oput '/media/target.md', '柳暗花明又一村'
            last_response.should be_ok
            IO.read(target).should == '柳暗花明又一村'
          end

          it 'should write successfully and return a 201 if file was created' do
            target = File.join(MEDIA_DIR, 'target.md')
            oput '/media/target.md', '山重水复疑无路'
            last_response.status.should == 201
            IO.read(target).should == '山重水复疑无路'
          end

          it 'should delete the specified page if it exists' do
            target = File.join(MEDIA_DIR, 'target.md')
            IO.write target, 'hello there this is jim', :mode => 'wb+'
            File.file?(target).should be_true
            odelete '/media/target.md'
            last_response.should be_ok
            File.file?(target).should be_false
          end

          # Prepares directory.
          def prep_dir
            FileUtils.mkdir File.join(MEDIA_DIR, 'test')
            child_file = File.join(MEDIA_DIR, 'test','partial.md')
            IO.write child_file, 'x', :mode => 'w+'
            File.file?(child_file).should be_true
            child_dir = File.join(MEDIA_DIR, 'test', 'foldr')
            FileUtils.mkdir child_dir
            File.directory?(child_dir).should be_true
          end

          it 'should return the directory listing as JSON' do

            prep_dir

            # check with and without trailing slashes
            oget '/media/test'
            last_response.should be_ok
            last_response.content_type.should match %r{^application/json;charset=utf-8}

            oget '/media/test/'
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
            oget '/media/', {}, {'HTTP_ACCEPT' => 'text/yaml'}
            last_response.should be_ok
            last_response.content_type.should match %r{^text/yaml;charset=utf-8}
          end

          it 'should return the directory listing as text' do
            oget '/media/', {}, {'HTTP_ACCEPT' => 'text/plain'}
            last_response.should be_ok
            last_response.content_type.should match %r{^text/plain;charset=utf-8}
          end

        end

        context 'malformed requests' do
          it 'should return 403 if resource path is not under +media+' do
            # TODO: both get and put
          end
        end

        context 'reading/writing to other files' do

          it 'should return a 404 if getting unknown resource' do
            oget '/media/xyz'
            last_response.should be_not_found
          end

          it 'should return a 409 if the target path is a directory' do
            target = File.join(MEDIA_DIR, 'target')
            FileUtils.mkdir_p target
            oput '/media/target', 'some content'
            last_response.status.should == 409
          end

          it 'should return a 404 if deleting unknown page' do
            odelete '/media/x'
            last_response.status.should == 404
          end

          it 'should return 403 if deleting directory' do
            FileUtils.mkdir File.join(MEDIA_DIR, 'x')
            odelete '/media/x'
            last_response.status.should == 403
          end

        end

      end

    end
  end
end
