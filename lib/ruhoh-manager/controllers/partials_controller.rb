require 'ruhoh-manager/controllers/files_controller'

class Ruhoh
  module Manager

    # Controls access to partials.
    # @author Jim Lim
    class PartialsController < FilesController

      protected

      def resolve_uri(uri)
        # TODO: multiple ruhohs
        return File.expand_path uri, Ruhoh.paths.partials
      end

      def is_allowed?(path)
        # TODO: multiple ruhohs
        (File.fnmatch? File.join(Ruhoh.paths.partials, '**'), path) ||
          (File.identical? Ruhoh.paths.partials, path)
      end

    end

  end
end
