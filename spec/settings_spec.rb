# encoding: utf-8
require 'spec_helper'

class Ruhoh
  module Manager
    module SettingsSpec

      describe 'Settings Controller' do

        include_context 'OAuth'
        include_context 'Blog'

        Names = OpenStruct.new(Ruhoh::Names)
        SITE_YML = File.join(Test::Blog::TEMP_SITE_PATH, Names.site_data)
        CONFIG_YML = File.join(Test::Blog::TEMP_SITE_PATH, Names.config_data)

        def app
          Api
        end

        context 'well-formed requests' do

          it 'should return site.yml as yaml' do
            oget '/settings/site', {}, {'HTTP_ACCEPT' => 'text/yaml'}
            last_response.should be_ok
            last_response.content_type.should match %r{^text/yaml}
            last_response.body.should == File.open(SITE_YML){ |f| f.read }
          end

          it 'should return site.yml as json' do
            oget '/settings/site', {}, {'HTTP_ACCEPT' => 'application/json'}
            last_response.should be_ok
            last_response.content_type.should match %r{^application/json}
            yaml = File.open(SITE_YML) { |f| f.read }
            last_response.body.should == YAML.load(yaml).to_json
          end

          it 'should return site.yml as text' do
            oget '/settings/site', {}, {'HTTP_ACCEPT' => 'text/plain'}
            last_response.should be_ok
            last_response.content_type.should match %r{^text/plain}
            last_response.body.should == File.open(SITE_YML) { |f| f.read }
          end

          it 'should return config.yml as yaml' do
            oget '/settings/config', {}, {'HTTP_ACCEPT' => 'text/yaml'}
            last_response.should be_ok
            last_response.content_type.should match %r{^text/yaml}
            last_response.body.should == File.open(CONFIG_YML) { |f| f.read }
          end

          it 'should return config.yml as json' do
            oget '/settings/config', {}, {'HTTP_ACCEPT' => 'application/json'}
            last_response.should be_ok
            last_response.content_type.should match %r{^application/json}
            yaml = File.open(CONFIG_YML) { |f| f.read }
            last_response.body.should == YAML.load(yaml).to_json
          end

          it 'should return config.yml as text' do
            oget '/settings/config', {}, {'HTTP_ACCEPT' => 'text/yaml'}
            last_response.should be_ok
            last_response.content_type.should match %r{^text/yaml}
            last_response.body.should == File.open(CONFIG_YML) { |f| f.read }
          end

          it 'should return payload as json' do
            oget '/settings/payload', {}, {'HTTP_ACCEPT' => 'application/json'}
            last_response.should be_ok
            last_response.content_type.should match %r{^application/json}
            last_response.body.should == Ruhoh::DB.payload.to_json
          end

          it 'should return payload as text' do
            oget '/settings/payload', {}, {'HTTP_ACCEPT' => 'text/plain'}
            last_response.should be_ok
            last_response.content_type.should match %r{^text/plain}
            last_response.body.should == Ruhoh::DB.payload.pretty_inspect
          end

          it 'should return payload as yml' do
            oget '/settings/payload', {}, {'HTTP_ACCEPT' => 'text/yaml'}
            last_response.should be_ok
            last_response.content_type.should match %r{^text/yaml}
            last_response.body.should == Ruhoh::DB.payload.to_yaml
          end

          it 'should overwrite site.yml' do
            oput '/settings/site', 'some 无聊的 UTF-8 text'
            last_response.should be_ok
            contents = File.open(SITE_YML, 'r:UTF-8') { |f| f.read }
            contents.should == "some 无聊的 UTF-8 text"
          end

          it 'should overwrite config.yml' do
            oput '/settings/config', 'some 无聊的 UTF-8 text'
            last_response.should be_ok
            contents = File.open(CONFIG_YML, 'r:UTF-8') { |f| f.read }
            contents.should == "some 无聊的 UTF-8 text"
          end

        end

         context 'malformed requests for config' do

          it 'should return JSON by default when Accepts is missing' do
            oget '/settings/config'
            last_response.should be_ok
            last_response.content_type.should match %r{application/json}
          end

          it 'should return JSON by default' do
            oget '/settings/config', {}, {'HTTP_ACCEPT' => 'application/js'}
            last_response.should be_ok
            last_response.content_type.should match %r{application/json}
          end

        end

        context 'reading/writing to other files' do

          it 'should never allow access to other files' do
            api = mock app
            api.should_receive(:mime_type).and_return('application/json')
            api.should_receive(:halt).and_throw(:halt)
            controller = Controllers::SettingsController.new api
            expect {
              controller.send :_get, 'x', ['application/json']
            }.to throw_symbol :halt
          end

          it 'should return a 404 if getting unknown resource' do
            oget '/settings/xyz', {} ,{'HTTP_ACCEPT' => 'application/json'}
            last_response.should be_not_found
            oget '/settings', {} ,{'HTTP_ACCEPT' => 'application/json'}
            last_response.should be_not_found
            oget '/settings/', {} ,{'HTTP_ACCEPT' => 'application/json'}
            last_response.should be_not_found
          end

          it 'should return a 404 if a known resource is missing' do
            File.delete CONFIG_YML
            oget '/settings/config', {}, {'HTTP_ACCEPT' => 'application/json'}
            last_response.should be_not_found
            oget '/settings/config', {}, {'HTTP_ACCEPT' => 'text/yaml'}
            last_response.should be_not_found
          end

          it 'should return a 403 if putting unknown resource' do
            oput '/settings/xyz'
            last_response.should be_forbidden
            oput '/settings'
            last_response.should be_forbidden
            oput '/settings/'
            last_response.should be_forbidden
          end

        end

      end

    end
  end
end
