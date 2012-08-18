class Ruhoh
  module Manager

    # Collection of helper methods for halting and returning status codes.
    # This can only be used in subclasses of {ApplicationController} because
    # it requires method delegation to a Sinatra app.
    module StatusCode

      # Set status to Forbidden and stop
      def forbidden(body = nil)
        error Rack::Utils.status_code(:forbidden), body
      end

      # Set status to Bad Request and stop
      def bad_request(body = nil)
        error Rack::Utils.status_code(:bad_request), body
      end

      # Set status to Conflict and stop
      def conflict(body = nil)
        error Rack::Utils.status_code(:conflict), body
      end

      # Set status to Internal Server Error and stop
      def internal_server_error(body=nil)
        error Rack::Utils.status_code(:internal_server_error), body
      end

      # Set status to OK and stop
      def ok
        halt Rack::Utils.status_code(:ok)
      end

      # Set status to Created and stop
      def created
        halt Rack::Utils.status_code(:created)
      end

    end

  end
end
