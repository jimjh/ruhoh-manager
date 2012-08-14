class Ruhoh
  class Manager < Sinatra::Base

    # Controls settings actions (for +site.yml+, +config.yml+, and +payload+).
    # @author Jim Lim
    class SettingsController < Manager::ApplicationController

      # @param [Sinatra::Base] app          sinatra application
      # @param [Sinatra::Request] request   http request
      def initialize(app, request)
        super app, request
        @allowed_paths = [Ruhoh.paths.site_data, Ruhoh.paths.config_data]
      end

      # GET /settings/config
      # @see #get
      # @return [String] response body
      def config
        get Ruhoh.paths.config_data, request.accept
      end

      # PUT /settings/config
      # @see #put
      # @return [String] response body
      def put_config
        put Ruhoh.paths.config_data, request.body.read
      end

      # GET /settings/site
      # @see #get
      # @return [String] response body
      def site
        get Ruhoh.paths.site_data, request.accept
      end

      # PUT /settings/site
      # @see #put
      # @return [String] response body
      def put_site
        put Ruhoh.paths.site_data, request.body.read
      end

      # GET /settings/payload
      # Returns the payload in the format requested.
      # * sets HTTP status to 406 if +types+ does not contain json, yaml, or
      #   text
      # @return [String] response body
      def payload
        request.accept.each { |type|
          case type
          when mime_type('.json')
            halt Ruhoh::DB.payload.to_json
          when mime_type('.yaml')
            halt Ruhoh::DB.payload.to_yaml
          when mime_type('.txt')
            require 'pp'
            halt Ruhoh::DB.payload.pretty_inspect
          else
            error status_code(:Not_Acceptable)
          end
        }
      end

      private

      # Serves the specified file if it is available.
      # * sets HTTP status code to 406 if +types+ does not include json, text, or
      #   yaml.
      # * sets HTTP status code to 404 if +path+ does not point to a valid file.
      # * sets HTTP status code to 403 if +path+ is not in +@allowed_paths+.
      # @param [String] path        path to the configuration file to serve
      # @param [Array]  types       array of acceptable mime types
      # @return [String] response body
      def get(path, types)
        error status_code(:Forbidden) if not is_allowed? path
        types.each { |type|
          case type
          when mime_type('.json')
            halt YAML::load_file(path).to_json
          when mime_type('.txt')
            halt send_file path, :type => :text
          when mime_type('.yaml')
            halt send_file path, :type => :yaml
          else
            error status_code(:Not_Acceptable)
          end
        }
      rescue Errno::ENOENT => e
        Friend.say { red e.message }
        error status_code(:Not_Found)
      end

      # (Over)writes the file at the specified path with +contents+
      # * sets HTTP staus to 403 if +path+ is not in +ALLOWED_PATHS+.
      # * sets HTTP status to 409 if an error is encountered while writing.
      # @param [String] path        path to the configuration file
      # @param [String] contents    file contents
      # @return [String] response body
      def put(path, contents)
        error status_code(:Forbidden) if not is_allowed? path
        File.open(path, 'w+') { |f|
          f.write contents
        }
        status Rack::Utils.status_code(:OK)
      rescue Errno::ENOENT => e
        Friend.say { red e.message }
        error status_code(:Conflict)
      end

      # Checks if +path+ is not array of allowed paths.
      # @param [String] path        path to check
      # @return [Boolean] true if path is allowed; false otherwise.
      def is_allowed?(path)
        return @allowed_paths.include? path
      end

    end
  end
end

