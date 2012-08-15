class Ruhoh
  module Manager

    # Controls posts actions
    # @author Jim Lim
    class PostsController < ApplicationController

      # Retrieves the file at the specified path as text.
      # @param [Array] splat    splat from sinatra mapping
      def get(splat)
        error status_code(:not_found) if splat.empty?
        path = File.expand_path splat[0], Ruhoh.paths.posts # TODO
        error status_code(:forbidden) unless is_allowed? path
        send_file path, :type => :text
        # send_file already handles Errno::ENOENT, so we are safe
      end

      # Writes the request body to a new file at the specified path.
      # Sets status code to 201 if a new file was created, or 200 if an
      # existing file was updated.
      # @param [Array] splat        splat from sinatra mapping; must
      #                             contain path to new file.
      def put(splat)

        error status_code(:bad_request) if splat.empty?
        path = File.expand_path splat[0], Ruhoh.paths.posts # TODO
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

      # Deletes the file at the given path.
      # * sets status code to Not Found is path does not exist
      # * sets status code to Forbidden is path points to a dir
      # @param [Array] splat        splat from sinatra mapping; must contain
      #                             path to file
      def delete(splat)

        error status_code(:bad_request) if splat.empty?
        path = File.expand_path splat[0], Ruhoh.paths.posts # TODO
        error status_code(:forbidden) unless is_allowed? path
        error status_code(:not_found) unless File.exists? path
        error status_code(:forbidden) unless File.file? path

        File.delete path
        halt status_code(:ok)

      rescue SystemCallError => e
        logger.error e.message
        error status_code(:internal_server_error)
      end


      private

      # @return [Boolean] true <=> path is a child of +Ruhoh.paths.posts+
      def is_allowed?(path)
        # TODO: handle multiple ruhohs
        File.fnmatch File.join(Ruhoh.paths.posts, '**'), path
      end

    end

  end
end
