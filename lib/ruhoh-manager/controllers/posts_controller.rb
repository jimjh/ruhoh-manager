require 'ruhoh-manager/controllers/files_controller'

class Ruhoh
  module Manager

    # Controls access to posts
    # @author Jim Lim
    class PostsController < FilesController

      protected

      def resolve_uri(uri)
        return File.expand_path uri, Ruhoh.paths.posts # TODO
      end

      # @return [Boolean] true <=> path is a child of +Ruhoh.paths.posts+
      def is_allowed?(path)
        # TODO: handle multiple ruhohs
        (File.fnmatch? File.join(Ruhoh.paths.posts, '**'), path) ||
          (File.identical? Ruhoh.paths.posts, path)
      end

    end

  end
end
