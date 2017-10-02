require 'rails/generators'

class TestAppGenerator < Rails::Generators::Base
  source_root File.expand_path("../../../../spec/test_app_templates", __FILE__)

  # if you need to generate any additional configuration
  # into the test app, this generator will be run immediately
  # after setting up the application

  def run_blacklight_generator
    say_status("warning", "GENERATING BL", :yellow)

    generate 'blacklight', '--devise'
  end

  # Add favicon.ico to asset path
  # ADD THIS LINE Rails.application.config.assets.precompile += %w( favicon.ico )
  # TO config/assets.rb
  def add_favicon_to_asset_path
    say_status("warning", "ADDING FAVICON TO ASSET PATH", :yellow)

    append_to_file 'config/initializers/assets.rb' do
      'Rails.application.config.assets.precompile += %w( favicon.ico )'
    end
  end

  # Override solr.yml to match settings needed for solr_wrapper.
  def update_solr_config
    say_status("warning", "COPYING SOLR.YML", :yellow)

    remove_file "config/solr.yml"
    copy_file "config/solr.yml", "config/solr.yml"
  end

  def install_engine
    say_status("warning", "GENERATING BL OAI PLUGIN", :yellow)

    generate 'blacklight_oai_provider:install'
  end

  def add_test_blacklight_oai_config
    say_status("warning", "ADDING BL OIA-PMH CONFIG")

    insert_into_file "app/controllers/catalog_controller.rb", :after => "    config.default_solr_params = { \n" do
      "      :fl => '*',\n"
    end

    insert_into_file "app/controllers/catalog_controller.rb", :after => "configure_blacklight do |config|\n" do
%{
    config.oai = {
        :provider => {
        :repository_name => 'Test',
        :repository_url => 'http://localhost',
        :record_prefix => '',
        :admin_email => 'root@localhost'
      },
      :document => {
        :timestamp => 'timestamp',
        :limit => 25
      }
    }
}
    end

    insert_into_file "app/models/solr_document.rb", :after => "  field_semantics.merge!(    \n" do
%{
    :creator => "author_display",
    :date => "pub_date",
    :subject => "subject_topic_facet",
}
    end
  end
end
