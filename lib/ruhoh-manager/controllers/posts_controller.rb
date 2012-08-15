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
