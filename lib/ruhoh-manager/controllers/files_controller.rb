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
        path = resolve_uri(splat[0] || '')
        _get path, request.accept
      end

      # Writes the request body to a new file at the specified uri.
      # Sets status code to 201 if a new file was created, or 200 if an
      # existing file was updated.
      # @param [Array] splat        splat from sinatra mapping; must
      #                             contain uri to new file.
      def put(splat)
        bad_request if splat.empty?
        _put resolve_uri(splat[0]), request.body.read
      end

      # Deletes the file at the given uri.
      # * sets status code to Not Found if file does not exist
      # * sets status code to Forbidden is uri points to a dir
      # @param [Array] splat        splat from sinatra mapping; must contain
      #                             uri to file
      def delete(splat)
        bad_request if splat.empty?
        _delete resolve_uri(splat[0])
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

      # Retrieves the file at +path+ or returns a directory listing.
      # @param [String] path          path to file
      # @param [Array] types          array of client accept types
      def _get(path, types)
        forbidden unless is_allowed? path
        not_found unless File.exists? path
        if File.file? path
          send_file path, :type => :text
        else
          send_directory path, types
        end
      end

      # Writes +contents+ to file at +path+.
      # @param [String] path        path to file
      # @param [String] contents    contents to write to file
      def _put(path, contents)
        forbidden unless is_allowed? path
        existed = File.file? path
        # ensure path exists, and write to file
        FileUtils.mkdir_p File.dirname(path)
        IO.write path, contents, :mode => 'wb+'
        existed ? ok : created
      rescue SystemCallError => e
        logger.error e.message
        conflict
      end

      # Deletes file at +path+ if it exists.
      # @param [String] path        path to file
      def _delete(path)
        forbidden unless is_allowed? path
        not_found unless File.exists? path
        forbidden unless File.file? path
        File.delete path
        ok
      rescue SystemCallError => e
        logger.error e.message
        internal_server_error
      end

      # Sends a directory listing
      # @param [String] path      path to directory
      # @param [Array] types          array of client accept types
      def send_directory(path, types)
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
        respond listing, types
      end

    end

  end
end

