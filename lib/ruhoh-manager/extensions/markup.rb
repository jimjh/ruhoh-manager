class Ruhoh
  module Manager

    # Helper module for generating markup.
    # Usage:
    #   class Api < Sinatra::Base
    #     helper Markup
    #   end
    module Markup

      # Generates an anchor link for +name+.
      # Examples:
      #   link_to 'my home', '/'
      # @param [String] name          display name
      # @return [String]
      def link_to(name = nil, *args)
        url = args.shift if args.first.to_s =~ /^\w.* ?:/
        "<a href=\"#{url}\">#{name || url}</a>"
      end

      # Prepends +path+ with {BASE_PATH}
      # @param [String] path     path relative to base path
      # @return [String]
      def path_to(path)
        BASE_PATH + path
      end

    end

  end
end
