class Ruhoh
  module Manager

    # Collection of helper methods for serialization.
    module Serializer

      # Serializes object and sends it as the HTTP response. Defaults to
      # JSON.
      # @param [Object] object        the object to serialize
      # @param [Array] types          request.types
      def respond(object, types)
        types << mime_type(:json)
        types.each { |type|
          case type
          when mime_type(:json)
            content_type :json, :charset => 'utf-8'
            halt object.to_json
          when mime_type(:yaml)
            content_type :yaml, :charset => 'utf-8'
            halt object.to_yaml
          when mime_type(:text)
            require 'pp'
            content_type :text, :charset => 'utf-8'
            halt object.pretty_inspect
          end
        }
      end

    end
  end
end
