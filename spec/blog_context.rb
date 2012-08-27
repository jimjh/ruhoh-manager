class Ruhoh
  module Manager
    module Test

      # Shared context for examples that require a blog.
      module Blog

        TEST_SITE_PATH = File.join(File.dirname(__FILE__), 'test-site')
        TEMP_SITE_PATH = File.expand_path '__tmp'

        shared_context 'Blog' do

          before(:each) { _create_temp_blog }
          after(:each) { _delete_temp_blog }

          private

          def _create_temp_blog
            FileUtils.mkdir TEMP_SITE_PATH
            FileUtils.cp_r File.join(TEST_SITE_PATH, '.'), TEMP_SITE_PATH
            # FIXME: I don't like this; change it when we can handle multiple ruhohs
            Ruhoh::Utils.stub(:parse_yaml_file).and_return('theme' => 'twitter')
            Ruhoh::Paths.stub(:theme_is_valid?).and_return(true)
            Ruhoh::Manager.setup_ruhoh source: TEMP_SITE_PATH, env: 'test'
          end

          def _delete_temp_blog
            FileUtils.remove_dir(TEMP_SITE_PATH, true) if Dir.exists? TEMP_SITE_PATH
            Ruhoh::Manager.reset_ruhoh
            # FIXME: change this after we can handle multiples
          end

        end

      end #/Blog

    end
  end
end
