# loads all controllers
Dir["#{File.dirname(__FILE__)}/controllers/*_controller.rb"].each { |f| load f }

class Ruhoh
  module Manager

    # Sinatra App that exposes a REST api for ruhoh administraton.
    class Api < Sinatra::Base

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

      # Routes to SettingsController#put_<action>
      put '/:controller/:action' do
        controller = settings_controller
        action = "put_#{params[:action]}"
        error 404, 'Unknown action' unless controller.respond_to? action
        controller.public_send action
      end

      private

      # Gets a new instance of the settings controller
      # @return [ApplicationController] settings controller
      def settings_controller
        SettingsController.new self, request
      end

    end
  end
end
