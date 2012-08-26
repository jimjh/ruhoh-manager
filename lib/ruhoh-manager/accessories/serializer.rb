class Ruhoh
  module Manager::Accessories

    # Collection of helper methods for serialization for use in controllers.
    # This can only be used in subclasses of {Controllers::ApplicationController}
    # because it requires method delegation to a Sinatra app.
    # Example:
    #   respond {:x => 'y'}, request.accept
    module Serializer

      # @return mime type for json
      def json
        mime_type :json
      end

      # @return mime type for yaml
      def yaml
        mime_type :yaml
      end

      # @return mime type for text
      def text
        mime_type :text
      end

      # Serializes object and sends it as the HTTP response using the preferred
      # mime type. Defaults to JSON.
      # @param [Object] object        the object to serialize
      # @param [Array] types          request.accept
      def respond(object, types)
        types << json
        types.each { |type|
          case type
          when json
            content_type :json, :charset => 'utf-8'
            halt object.to_json
          when yaml
            content_type :yaml, :charset => 'utf-8'
            halt object.to_yaml
          when text
            content_type :text, :charset => 'utf-8'
            halt object.pretty_inspect
          end
        }
      end

    end
  end
end
