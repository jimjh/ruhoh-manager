class Ruhoh
  module Manager

    # Controls posts actions
    # @author Jim Lim
    class PostsController < ApplicationController

      # Retrieves the file at the specified path.
      # @param [Array] splat    splat from sinatra mapping
      def get(splat)
        # TODO security
        error status_code(:not_found) if splat.empty?
        error status_code(:not_acceptable) unless is_accepted? request.accept
        path = File.expand_path splat[0], Ruhoh.paths.posts # TODO
        error status_code(:forbidden) unless is_allowed? path
        send_file path, :type => :text
      end

      private

      def is_allowed?(path)
        File.fnmatch File.join(Ruhoh.paths.posts, '**'), path
      end

      # @return [Boolean] true if types contains text/plain
      def is_accepted?(types)
        types.include? mime_type('.txt')
      end

    end

  end
end
