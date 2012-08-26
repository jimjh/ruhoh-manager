class Ruhoh
  module Manager::Extensions

    # Adds convenience conditions
    #
    # Usage:
    #   class App < Sinatra::Base
    #     register Conditional
    #   end
    #
    # Examples:
    #   before ..., :method => [:get, :head] do
    #     ...
    #   end
    module Conditional

      class << self

        # Called when this extension is registered.
        # @param [Sinatra::Base] app        sinatra application
        def registered(app)
          _method app
        end

        private

        # Installs the +:method+ conditional.
        # @param [Sinatra::Base] app        sinatra application
        def _method(app)
          app.set(:method) do |*methods|
            app.condition do
              method = env['REQUEST_METHOD'].downcase.to_sym
              methods.include? method
            end
          end
        end

      end

    end

  end
end
