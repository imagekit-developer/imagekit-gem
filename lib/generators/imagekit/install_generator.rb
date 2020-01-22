require 'securerandom'

module Imagekit
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)
      desc "Creates imagekit initializer for the application"

      def copy_initializer
        template "imagekit_initializer.rb", "config/initializers/imagekit.rb"

        puts "Installation complete! Truly Amazing!"
      end
    end
  end
end
