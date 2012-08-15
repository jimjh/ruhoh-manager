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

      # Routes to SettingsController#action
      get '/settings/:action', :provides => [:json, :yaml, :text] do
        controller = settings_controller
        error 404, 'Unknown action' unless controller.respond_to? params[:action]
        controller.public_send params[:action]
      end

      get '/settings/:action' do
        error 406
      end

      # Routes to SettingsController#put_<action>
      put '/settings/:action' do
        controller = settings_controller
        action = "put_#{params[:action]}"
        error 404, 'Unknown action' unless controller.respond_to? action
        controller.public_send action
      end

      # Generic route (for pages, posts, media, partials)
      get '/:controller/?*' do
        controller = create_controller params[:controller]
        controller.get params[:splat]
      end

      private

      # Gets a new instance of the settings controller
      # @return [ApplicationController] settings controller
      def settings_controller
        create_controller 'settings'
      end

      # Gets a new instance of the specified controller
      # @param [String] controller_str    e.g. +pages+, +posts+
      # @return [ApplicationController] controller
      def create_controller(controller_str)
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
