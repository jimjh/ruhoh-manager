# load application controller first
require "ruhoh-manager/controllers/application_controller"

class Ruhoh
  module Manager

    # Collection of helper functions for the Api class.
    module ApiHelper

      # Loads all controllers that match
      # +ruhoh-manager/controllers/*_controller.rb+
      def load_controllers
        # loads all other controllers
        dir = File.join(File.dirname(__FILE__), 'controllers', '*_controller.rb')
        Dir[dir].each { |controller| load controller }
      end

    end

    # Sinatra App that exposes a REST api for ruhoh administration.
    class Api < Sinatra::Base
      extend ApiHelper

      load_controllers

      configure :production do
        enable :logging
      end

      configure :development do
        enable :logging, :dump_errors
      end

      # Registers YAML mime-type
      mime_type :yaml, 'application/x-yaml'

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
        not_found unless controller.respond_to? method
        controller.public_send method, params[:splat]
      end

      # Gets a new instance of the specified controller
      # @param [String] controller_str    e.g. +pages+, +posts+
      # @return [ApplicationController] controller
      def _create_controller(controller_str)
        controller_name = "#{controller_str.capitalize}Controller"
        begin
          error 404, 'Unknown controller' unless Manager.const_defined? controller_name
        rescue NameError => e
          logger.error e.message
          error 404, 'Unknown controller'
        end
        controller_cls = Manager.const_get controller_name
        controller_cls.new self
      end

    end
  end
end
