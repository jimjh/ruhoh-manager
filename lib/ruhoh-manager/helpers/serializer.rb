class Ruhoh
  module Manager

    module Serializer

      def respond(object, types)
        types.each { |type|
          case type
          when mime_type(:json)
            content_type :json
            halt object.to_json
          when mime_type(:yaml)
            content_type :yaml
            halt object.to_yaml
          when mime_type(:text)
            require 'pp'
            content_type :text
            halt object.pretty_inspect
          end
        }
      end

    end
  end
end
