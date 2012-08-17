require "ruhoh-manager/controllers/application_controller"

class Ruhoh
  module Manager

    # Abstract class that controls access to file resources
    # @abstract
    # @author Jim Lim
    class FilesController < ApplicationController

      # Retrieves the file at the specified uri as text. If the uri
      # points to a directory, returns a listing of the files in that
      # directory.
      # @param [Array] splat        splat from sinatra mapping; must
      #                             contain uri to new file.
      def get(splat)

        uri = splat[0] || ''
        path = resolve_uri uri

        error status_code(:forbidden) unless is_allowed? path
        error status_code(:not_found) unless File.exists? path
        if File.file? path
          send_file path, :type => :text
        else
          send_directory path
        end

      end

      # Writes the request body to a new file at the specified uri.
      # Sets status code to 201 if a new file was created, or 200 if an
      # existing file was updated.
      # @param [Array] splat        splat from sinatra mapping; must
      #                             contain uri to new file.
      def put(splat)

        error status_code(:bad_request) if splat.empty?
        path = resolve_uri splat[0]
        error status_code(:forbidden) unless is_allowed? path

        res = (File.file? path) ? :ok : :created

        # ensure path exists, and write to file
        FileUtils.mkdir_p File.dirname(path)
        IO.write path, request.body.read, :mode => 'wb+'
        halt status_code(res)

      rescue SystemCallError => e
        logger.error e.message
        error status_code(:conflict)
      end

      # Deletes the file at the given uri.
      # * sets status code to Not Found if file does not exist
      # * sets status code to Forbidden is uri points to a dir
      # @param [Array] splat        splat from sinatra mapping; must contain
      #                             uri to file
      def delete(splat)

        error status_code(:bad_request) if splat.empty?
        path = resolve_uri splat[0]
        error status_code(:forbidden) unless is_allowed? path
        error status_code(:not_found) unless File.exists? path
        error status_code(:forbidden) unless File.file? path

        File.delete path
        halt status_code(:ok)

      rescue SystemCallError => e
        logger.error e.message
        error status_code(:internal_server_error)
      end

      protected

      # Converts uri to file path.
      # E.g. +/cars/ferrari.md+ -> +/usr/codex/posts/cars/ferrari.md+
      # @abstract
      # @param [String] uri     uri of resource
      # @return [String]        resolved file path
      def resolve_uri(uri)
        raise :unimplemented
      end

      # Checks if the given path is allowed by this controller. Invoked by
      # #get, #put, and #delete before any file I/O is done.
      # @abstract
      # @param [String] path      path to file/directory
      # @return [Boolean] true <=> path is allowed
      def is_allowed?(path)
        raise :unimplemented
      end

      private

      # Sends a directory listing
      # @param [String] path      path to directory
      def send_directory(path)
        # TODO: use git ls
        listing = []
        Dir[File.join path, '*'].each { |child|
          stat = File.stat child
          listing << {
            :name => (File.basename child),
            :type => stat.ftype,
            :size => stat.size
          }
        }
        respond listing, request.accept
      end

    end

  end
end

