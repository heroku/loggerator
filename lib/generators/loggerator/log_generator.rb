module Loggerator
  class LogGenerator < Rails::Generators::Base

    desc "Creates an initializer for Loggerator logs at config/initializer/log.rb"
    class_option :a, banner: "APP_NAME", desc: "Specify APP_NAME instead of the one defined by Rails"
    source_root File.expand_path("../../templates", __FILE__)

    def create_config_file
      template "log.rb.erb", "config/initializers/log.rb"
    end

    private
      def app_name
        options[:a] || Rails.root.basename
      end
  end
end
