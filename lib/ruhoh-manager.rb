# encoding: UTF-8
Encoding.default_internal = 'UTF-8'
require 'yaml'
require 'psych'
YAML::ENGINE.yamler = 'psych'

require 'sinatra/base'
require 'json'
require 'ruhoh'

require "ruhoh-manager/version"
require 'ruhoh-manager/api'

class Ruhoh
  module Manager

    def self.launch(opts={})
      opts[:env] ||= 'development'

      Ruhoh.setup       # TODO: smarter paths
      Ruhoh.config.env = opts[:env]
      Ruhoh::DB.update_all

      Rack::Builder.new {
        use Rack::Lint
        use Rack::ShowExceptions
        map '/admin' do
          run Ruhoh::Manager::Api
        end
      }

    end

  end
end
