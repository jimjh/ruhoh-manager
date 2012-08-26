require 'ruhoh-manager/controllers/files_controller'

class Ruhoh
  module Manager::Controllers

    # Controls access to media (e.g. images, audio)
    # @author Jim Lim
    class MediaController < FilesController

      private

      def resolve_uri(uri)
        return File.expand_path uri, Ruhoh.paths.media
      end

      def is_allowed?(path)
        (File.fnmatch? File.join(Ruhoh.paths.media, '**'), path) ||
          (File.identical? Ruhoh.paths.media, path)
      end

    end

  end
end
