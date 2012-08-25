class Ruhoh
  module Manager

    # Methods for loading controllers and helpers.
    # Usage:
    #   class Api < Sinatra::Base
    #     register Loader
    #     ...
    #   end
    module Loader
      class << self

        # Called when the loader is registered. Installs Rack::Utils and loads
        # controllers, helpers.
        # @param [Sinatra::Base] app        sinatra application
        def registered(app)
          app.helpers do
            include Rack::Utils
            app.send :alias_method, :h, :escape_html
          end
          load_helpers
          load_controllers
        end

        # Loads all controllers that match
        # +ruhoh-manager/controllers/*_controller.rb+
        def load_controllers
          load_glob File.join('controllers', '*_controller.rb')
        end

        # Loads all helpers in the helpers directory.
        def load_helpers
          load_glob File.join('helpers', '*.rb')
        end

        # Loads all files that match the given +glob+ (relative to
        # lib/ruhoh-manager)
        # @param [String] glob        UNIX glob
        def load_glob(glob)
          glob = File.join(File.dirname(__FILE__), '..', glob)
          Dir[glob].each { |f| load f }
        end

      end
    end

  end
end
