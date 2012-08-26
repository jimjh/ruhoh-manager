class Ruhoh
  module Manager::Controllers

    # Super class for all manager controllers. Does plumbing to provide
    # helper methods for child classes.
    class ApplicationController

      # Includes all accessories in the {Accessories} module.
      def self.include_accessories
        Manager::Accessories.constants.each { |acc|
          include Manager::Accessories.const_get(acc)
        }
      end
      private_class_method :include_accessories

      extend Forwardable
      include_accessories

      # Forwards methods to app delegate
      def_delegators :@app, :send_file, :mime_type, :status,
                            :halt, :logger, :request, :content_type

      # @param [Sinatra::Base] app          sinatra application
      def initialize(app)
        @app = app
      end

      private

      attr_reader :app

    end

  end
end
