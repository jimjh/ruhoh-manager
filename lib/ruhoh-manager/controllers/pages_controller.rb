class Ruhoh
  module Manager

    # Controls access to pages.
    # @author Jim Lim
    class PagesController < FilesController

      protected

      def resolve_uri(uri)
        # TODO: multiple ruhohs
        return File.expand_path uri, Ruhoh.paths.pages
      end

      def is_allowed?(path)
        # TODO: multiple ruhohs
        File.fnmatch File.join(Ruhoh.paths.pages, '**'), path
      end

    end

  end
end
