require 'ruhoh-manager/extensions/loader'

class Ruhoh
  module Manager

    # Sinatra App that exposes a REST api for ruhoh administration.
    class Api < Sinatra::Base

      register Extensions::Loader
      register Extensions::Conditional
      register Extensions::OAuth2
      helpers Extensions::Markup

      configure :production do
        enable :logging
      end

      configure :development do
        enable :logging, :dump_errors
      end

      configure :test do
      end

      get '/:controller/?*' do
        _invoke :get, params
      end

      put '/:controller/?*' do
        _invoke :put, params
      end

      delete '/:controller/?*' do
        _invoke :delete, params
      end

      private

      # Invokes +method+ in controller. Throws 404 if method is missing in
      # controller.
      # @param [Symbol] method          method name
      # @param [Array]  params          params from sinatra (must contain
      #                                 +:controller+ and +:splat+)
      def _invoke(method, params)
        controller = _create_controller params[:controller]
        _missing :action unless controller.respond_to? method
        controller.public_send method, params[:splat]
      end

      # Gets a new instance of the specified controller
      # @param [String] controller_str    e.g. +pages+, +posts+
      # @return [ApplicationController] controller
      def _create_controller(controller_str)
        controller_name = "#{controller_str.capitalize}Controller"
        begin
          _missing :controller unless Controllers.const_defined? controller_name
        rescue NameError => e
          logger.error e.message
          _missing :controller
        end
        controller_cls = Controllers.const_get controller_name
        controller_cls.new self
      end

      # Raises a 404 for missing +type+.
      # @param [String] type      e.g. action, controller
      def _missing(type)
        content_type :json
        error 404, {message: "Unknown #{type}"}.to_json
      end

    end
  end
end
