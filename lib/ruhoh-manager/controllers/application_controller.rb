require 'forwardable'

class Ruhoh
  module Manager

    # Super class for all manager controllers. Does plumbing to provide
    # helper methods for child classes.
    # @author Jim Lim
    class ApplicationController

      extend Forwardable
      include Serializer

      # Forwards methods to app delegate and rack utils
      def_delegators :@app, :send_file, :mime_type, :error,
                            :status, :halt, :logger, :request,
                            :content_type
      def_delegators :'Rack::Utils', :status_code

      # @param [Sinatra::Base] app          sinatra application
      def initialize(app)
        @app = app
      end

      protected

      attr_reader :app

    end

  end
end
