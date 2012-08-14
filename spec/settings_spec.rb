require 'bacon'
require 'rack/test'

module SettingsSpec

  ENV['RACK_ENV'] = 'test'

  def app
    Sinatra::Application
  end

  describe 'Settings Controller' do
    include Rack::Test::Methods

    it 'should return site.yml as yaml' do
    end

    it 'should return site.yml as json' do
    end

    it 'should return site.yml as text' do
    end

    it 'should return config.yml as yaml' do
    end

    it 'should return config.yml as json' do
    end

    it 'should return config.yml as text' do
    end

    it 'should return payload as json' do
    end

    it 'should return payload as yml' do
    end

    it 'should return payload as text' do
    end

    it 'should overwrite site.yml' do
    end

    it 'should overwrite config.yml' do
    end

  end

end
