require 'sinatra/base'

# loads all controllers
Dir["#{File.dirname(__FILE__)}/*_controller.rb"].each { |f| load f }

class Ruhoh

  # Sinatra App for CMS. Defines our REST-ish API.
  # @author Jim Lim
  class Manager < Sinatra::Base

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
