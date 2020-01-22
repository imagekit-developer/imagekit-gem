require "imagekit/version"
require "imagekit/uploader"

module Imagekit
  autoload :Utils, 'imagekit/utils'
  autoload :Uploader, 'imagekit/uploader'
  autoload :PreloadedFile, "imagekit/preloaded_file"
  autoload :CarrierWave, "imagekit/carrier_wave"

  # Exception class
  class ImagekitException < StandardError;end

  # Constants
  USER_AGENT = "ImagekitRuby/" + VERSION
  SECURED_ENDPOINT   = 'https://ik.imagekit.io'
  UNSECURE_ENDPOINT  = 'http://ik.imagekit.io'

  # This is class for initialize the secret key
  class Configuration
    attr_accessor :public_key, :private_key, :imagekit_id, :use_subdomain, :use_secure

    def initialize
      self.public_key    = nil
      self.private_key   = nil
      self.imagekit_id   = nil
      self.use_subdomain = false
      self.use_secure    = true
    end
  end

  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||=  Configuration.new
  end

  def self.configure
    yield(configuration) if block_given?
  end

  def self.generate_signature(params_hash)
    sorted_params = self.sort_params(params_hash)
    paramsstring  = CGI.unescape(sorted_params.to_query)
    checksum = OpenSSL::HMAC.hexdigest('sha1', Imagekit.configuration.private_key, paramsstring)
  end

  def self.sort_params(params_hash)
    sorted_params_hash = {}
    sorted_keys = params_hash.keys.sort{|x, y| x <=> y}
    sorted_keys.each do |k|
      sorted_params_hash[k] = params_hash[k]
    end
    sorted_params_hash
  end

end

require "imagekit/helper" if defined?(::ActionView::Base)
require "imagekit/railtie" if defined?(Rails) && defined?(Rails::Railtie)
