class Ruhoh
  module Manager

    # An accessory is a helper for controllers. Every accessory defined in this
    # directory _and_ within the +Accessory+ module is automatically included
    # in every controller.
    #
    # Example:
    #   module Accessory::Serializer
    #     def useful_method
    #       ...
    #     end
    #   end
    #
    #   # in x_controller.rb
    #   class XController < ApplicationController
    #     # useful_method is available here
    #   end
    module Accessories
    end

  end
end
