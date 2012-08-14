require 'forwardable'

class Ruhoh
  module Manager

    # Super class for all manager controllers.
    # @author Jim Lim
    class ApplicationController

      extend Forwardable

      # Forwards methods to app delegate and rack utils
      def_delegators :@app, :send_file, :mime_type, :error, :status, :halt
      def_delegators :'Rack::Utils', :status_code

      # @param [Sinatra::Base] app          sinatra application
      # @param [Sinatra::Request] request   http request
      def initialize(app, request)
        @app = app
        @request = request
      end

      protected

      attr_reader :app, :request

    end

  end
end
