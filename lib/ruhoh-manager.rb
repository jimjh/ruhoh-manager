# encoding: UTF-8
Encoding.default_internal = 'UTF-8'
require 'yaml'
require 'psych'
YAML::ENGINE.yamler = 'psych'

require 'sinatra/base'
require 'json'
require 'ruhoh'

require 'ruhoh-manager/version'
require 'ruhoh-manager/loader'
require 'ruhoh-manager/oauth'
require 'ruhoh-manager/api'

class Ruhoh
  module Manager

    # Public: launches the sinatra app that serves the REST api.
    # @param [Hash] opts         hash of options
    def self.launch(opts={})

      opts[:env] ||= 'development'

      # FIXME: handle multiple ruhohs
      setup
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

    # Internal: prepares the manager and the ruhoh app
    def self.setup(opts={})
      Ruhoh.setup opts       # TODO: handle multiple ruhohs
      Ruhoh.setup_paths
      Ruhoh.setup_urls
      Ruhoh.setup_plugins unless opts[:enable_plugins] == false
    end

    # Internal: resets the manager
    def self.reset(*args)
      Ruhoh.reset(*args)
    end

  end
end
