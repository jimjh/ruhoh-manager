class Ruhoh
  module Manager

    # base path (TODO: allow configuration.)
    BASE_PATH = '/admin'

    # Manages configuration options from files in the +config+ directory.
    #
    # Example:
    #   ---
    #   # config/oauth.yml
    #   development:
    #     here:
    #       are:
    #         some: 'nested options'
    #   production:
    #     # bunch of options ...
    #
    # Usage:
    #   Config.generate 'development'
    # returns
    #  #<OpenStruct oauth={'here'=>{'are'=>{'some'=>'nested options'}}}>
    module Config

      class << self

        # Generates configuration from yaml files in the +config+ directory.
        # @param [String] env       environment
        # @return [Struct] struct containing configuration options.
        # TODO: allow user overrides.
        def generate(env)
          config = {}
          config_files.each do |file|
            base = File.basename file, '.yml'
            config[base.to_sym] = load_yaml file, env
          end
          OpenStruct.new config
        end

        private

        # Returns array of all yaml files under the +config+ directory.
        # @return [Array] array of paths to configuration files.
        def config_files
          Dir[File.join Manager.root, Manager.names.config, '*.yml']
        end

        # @param [String] file          path to config file
        # @param [String] env           environment
        # @return [Hash] hash of options for the specified environment.
        def load_yaml(file, env)
          yaml = Ruhoh::Utils.parse_yaml_file file
          raise "Bad configuration file: #{file}" if yaml.nil?
          yaml[env]
        end

      end

    end # /Config

  end
end
