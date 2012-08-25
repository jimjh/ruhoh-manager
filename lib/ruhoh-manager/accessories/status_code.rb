class Ruhoh
  module Manager

    # Collection of helper methods for halting and returning status codes.
    # This can only be used in subclasses of {ApplicationController} because
    # it requires method delegation to a Sinatra app.
    module Accessory::StatusCode

      # Set status to Forbidden and stop.
      def forbidden(body = nil)
        json_halt Rack::Utils.status_code(:forbidden), body
      end

      # Set status to Bad Request and stop.
      def bad_request(body = nil)
        json_halt Rack::Utils.status_code(:bad_request), body
      end

      # Set status to Conflict and stop.
      def conflict(body = nil)
        json_halt Rack::Utils.status_code(:conflict), body
      end

      # Set status to Not Found and stop.
      def not_found(body = nil)
        json_halt Rack::Utils.status_code(:not_found), body
      end

      # Set status to Internal Server Error and stop.
      def internal_server_error(body = nil)
        json_halt Rack::Utils.status_code(:internal_server_error), body
      end

      # Set status to OK and stop.
      def ok(body = nil)
        json_halt Rack::Utils.status_code(:ok), body
      end

      # Set status to Created and stop.
      def created(body = nil)
        json_halt Rack::Utils.status_code(:created), body
      end

      # Sets status to +code+ and stop. Body contains json +message+.
      # @param [Numeric] code           status code
      # @param [String] message         message body
      # Example:
      #   json_halt 404, "Not found" #>> {"message": "Not found."}
      def json_halt(code, message)
        halt code,
             {'Content-Type' => mime_type(:json)},
             {message: message}.to_json
      end

    end

  end
end
