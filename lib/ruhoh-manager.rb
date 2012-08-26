require 'ruhoh'
require 'forwardable'
require 'pp'

require 'sinatra/base'
require 'rack/oauth2/sinatra'

require 'ruhoh-manager/version'
require 'ruhoh-manager/config'

class Ruhoh
  module Manager

    # Names of configuration files.
    Names = {
      config: 'config'                      # directory containing config files
    }
    # Gem root.
    @root = File.dirname __FILE__
    # Struct containing names of configuration files.
    @names = OpenStruct.new Names

    class << self

      attr_reader :config, :root, :names

      # Public: launches the sinatra app that serves the REST api.
      # = Options
      # - +:env+ - one of +'development'+, +'test'+, or +'production'.
      # @param [Hash] opts         hash of options
      def launch(opts={})

        opts[:env] ||= 'development'

        setup opts
        setup_ruhoh opts
        Ruhoh::DB.update_all # FIXME

        require 'ruhoh-manager/api'
        Rack::Builder.new {
          use Rack::Lint
          use Rack::ShowExceptions
          map BASE_PATH do
            run Ruhoh::Manager::Api
          end
        }

      end

      # Internal: prepares the manager and the ruhoh app
      def setup(opts={})
        @config = Manager::Config.generate opts[:env]
        !!@config
      end

      # Internal
      # FIXME: handle multiple ruhohs
      def setup_ruhoh(opts={})
        reset_ruhoh
        Ruhoh.setup opts
        Ruhoh.setup_paths
        Ruhoh.setup_urls
        Ruhoh.setup_plugins unless opts[:enable_plugins] == false
        Ruhoh.config.env = opts[:env]
      end

      # Internal: resets ruhoh
      def reset_ruhoh(*args)
        Ruhoh.reset(*args)
      end

      # Internal: retrieves the mongo database.
      # @return [Mongo::DB] mongo database
      def database
        ensure_config
        return @db unless @db.nil?
        opts = config.database
        @db = Mongo::Connection.new(opts['host'], opts['port']).db(opts['name'])
      end

      private

      # Raise an exception if +config+ has not been initialized.
      def ensure_config
        raise "Config has not been generated yet." if @config.nil?
      end

    end # /self

  end # /Manager
end
