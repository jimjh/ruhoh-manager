class Ruhoh
  module Manager::Extensions

    # Methods for loading controllers, accessories, and extensions.
    # Usage:
    #   class Api < Sinatra::Base
    #     register Loader
    #     ...
    #   end
    module Loader
      class << self

        # ---------------------------------------------------------------------
        # Loader Class Context
        # ---------------------------------------------------------------------

        # Called when the loader is registered. Installs Rack::Utils and loads
        # controllers, accessories.
        # @param [Sinatra::Base] app        sinatra application
        def registered(app)
          app.helpers do
            include Rack::Utils
            app.send :alias_method, :h, :escape_html
          end
          load_accessories
          load_controllers
          load_extensions
        end

        private

        # Loads all controllers that match
        # +ruhoh-manager/controllers/*_controller.rb+
        def load_controllers
          load_glob File.join('controllers', 'application_controller.rb')
          load_glob File.join('controllers', '*_controller.rb')
        end

        # Loads all accessories in the accessories directory.
        # i.e. +ruhoh-manager/accessories/*.rb+
        def load_accessories
          load_glob File.join('accessories', '*.rb')
        end

        # Loads all extensions in the extensions directory.
        # i.e. +ruhoh-manager/extensions/*.rb+
        def load_extensions
          load_glob File.join('extensions', '*.rb')
        end

        # Loads all files that match the given +glob+
        # @param [String] glob    UNIX glob, relative to +lib/ruhoh-manager+
        def load_glob(glob)
          glob = File.join(File.dirname(__FILE__), '..', glob)
          Dir[glob].each { |f| load f }
        end

      end
    end

  end
end
