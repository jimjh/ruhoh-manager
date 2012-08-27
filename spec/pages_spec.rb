# encoding: utf-8
require 'spec_helper'

class Ruhoh
  module Manager
    module PagesSpec

      describe 'Pages Controller' do

        include_context 'OAuth'
        include_context 'Blog'

        Names = OpenStruct.new(Ruhoh::Names)
        PAGES_DIR = File.join(Test::Blog::TEMP_SITE_PATH, Names.pages)

        def app
          Api
        end

        context 'well-formed requests' do

          it 'should return pages as text' do
            f = File.join PAGES_DIR, 'hello_test.md'
            IO.write f, 'ただいま', :mode => 'wb+'
            oget '/pages/hello_test.md'
            last_response.should be_ok
            last_response.content_type.should match %{^text/plain;charset=utf-8}
            last_response.body.force_encoding('utf-8').should == 'ただいま'
          end

          it 'should handle pages within directories' do
            f = File.join(PAGES_DIR, 'some', 'nested', 'structure', 'x.md')
            FileUtils.mkdir_p File.dirname(f)
            IO.write f, '«»≈≠Ωº', :mode => 'wb+'
            oget '/pages/some/nested/structure/x.md'
            last_response.should be_ok
            last_response.content_type.should match %{^text/plain;charset=utf-8}
            last_response.body.force_encoding('utf-8').should == '«»≈≠Ωº'
          end

          it 'should write successfully and return a 200 if file exists' do
            target = File.join(PAGES_DIR, 'target.md')
            IO.write target, 'here is some english text', :mode => 'wb+'
            oput '/pages/target.md', '柳暗花明又一村'
            last_response.should be_ok
            IO.read(target).should == '柳暗花明又一村'
          end

          it 'should write successfully and return a 201 if file was created' do
            target = File.join(PAGES_DIR, 'target.md')
            oput '/pages/target.md', '山重水复疑无路'
            last_response.status.should == 201
            IO.read(target).should == '山重水复疑无路'
          end

          it 'should delete the specified page if it exists' do
            target = File.join(PAGES_DIR, 'target.md')
            IO.write target, 'hello there this is jim', :mode => 'wb+'
            File.file?(target).should be_true
            odelete '/pages/target.md'
            last_response.should be_ok
            File.file?(target).should be_false
          end

        end

        context 'malformed requests' do
          it 'should return 403 if resource path is not under +pages+' do
            # TODO: both get and put
          end
        end

        context 'reading/writing to other files' do

          it 'should return a 404 if getting unknown resource' do
            oget '/pages/xyz'
            last_response.should be_not_found
          end

          it 'should return a 409 if the target path is a directory' do
            target = File.join(PAGES_DIR, 'target')
            FileUtils.mkdir_p target
            oput '/pages/target', 'some content'
            last_response.status.should == 409
          end

          it 'should return a 404 if deleting unknown page' do
            odelete '/pages/x'
            last_response.status.should == 404
          end

          it 'should return 403 if deleting directory' do
            FileUtils.mkdir File.join(PAGES_DIR, 'x')
            odelete '/pages/x'
            last_response.status.should == 403
          end

        end

      end

    end
  end
end
