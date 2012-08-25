class Ruhoh
  module Manager

    # Controls settings actions (for +site.yml+, +config.yml+, and +payload+).
    # @author Jim Lim
    class SettingsController < ApplicationController

      # Retrieves the specified (+splat+) resource.
      # @see #_get
      # @see #_payload
      # @param [Array] splat    splat from sinatra mapping
      def get(splat)
        not_found if splat.empty?
        # TODO: handle multiple ruhoh instances
        case splat[0]
        when 'config'
          _get Ruhoh.paths.config_data, request.accept
        when 'site'
          _get Ruhoh.paths.site_data, request.accept
        when 'payload'
          _payload request.accept
        else
          not_found
        end
      end

      # Puts the specified (+splat+) resource.
      # @see #_put
      # @param [Array] splat    splat from sinatra mapping
      def put(splat)
        bad_request if splat.empty?
        case splat[0]
        when 'config'
          _put Ruhoh.paths.config_data, request.body.read
        when 'site'
          _put Ruhoh.paths.site_data, request.body.read
        else
          forbidden
        end
      end

      private

      # Returns the payload in the format requested. Defaults to JSON.
      # @param [Array] types      array of acceptable mime types
      # @return [String] response body
      def _payload(types)
        respond Ruhoh::DB.payload, types
      end

      # Serves the specified file if it is available. If +types+ is empty,
      # defaults to JSON.
      # * sets HTTP status code to 404 if +path+ does not point to a valid file.
      # * sets HTTP status code to 403 if +path+ is not in +@allowed_paths+.
      # @param [String] path        path to the configuration file to serve
      # @param [Array]  types       array of acceptable mime types
      # @return [String] response body
      def _get(path, types)
        forbidden if not is_allowed? path
        types << json
        types.each { |type|
          case type
          when json
            content_type :json
            halt YAML::load_file(path).to_json
          when text
            send_file path, :type => :text
          when yaml
            send_file path, :type => :yaml
          end
        }
      rescue SystemCallError => e
        # we are trying to get sth, but we can't, so I guess the correct
        # status code is not found.
        logger.error e.message
        not_found
      end

      # (Over)writes the file at the specified path with +contents+
      # * sets HTTP staus to 403 if +path+ is not in +ALLOWED_PATHS+.
      # * sets HTTP status to 409 if an error is encountered while writing.
      # @param [String] path        path to the configuration file
      # @param [String] contents    contents (written to file in binary)
      # @return [String] response body
      def _put(path, contents)
        forbidden if not is_allowed? path
        IO.write path, contents, :mode => 'wb+'
        ok
      rescue SystemCallError => e
        # we are trying to put sth, but we can't, so I guess the correct status
        # code is conflict.
        logger.error e.message
        conflict
      end

      # Checks if +path+ is not array of allowed paths.
      # @param [String] path        path to check
      # @return [Boolean] true if path is allowed; false otherwise.
      def is_allowed?(path)
        return allowed_paths.include? path
      end

      # @return [Array] array of allowed paths
      def allowed_paths
        # TODO: handle multiple instances
        [Ruhoh.paths.site_data, Ruhoh.paths.config_data]
      end

    end
  end
end

