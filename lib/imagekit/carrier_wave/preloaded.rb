# Support for store in CarrierWave files that were preloaded to imagekit (e.g., by javascript)
# Field value must be in the format:  "image/upload/v<version>/<public_id>.<format>#<signature>"
module Imagekit::CarrierWave
  PRELOADED_IMAGEKIT_PATH = Imagekit::PreloadedFile::PRELOADED_IMAGEKIT_PATH
  STORED_IMAGKIT_PATH = /^([^\/]+)\/([^\/]+)\/v(\d+)\/([^#]+)$/
  SHORT_STORED_IMAGKIT_PATH = /^v(\d+)\/([^#]+)$/

  def cache!(new_file)
    file = Imagekit::CarrierWave::createRawOrPreloaded(new_file)
    if file
      @file = file
      @stored_version = @file.version
      @public_id = @stored_public_id = @file.public_id
      self.original_filename = sanitize(@file.original_filename)
      @cache_id = "unused" # must not be blank 
    else
      super
      @public_id = nil # allow overriding public_id
    end
  end

  def retrieve_from_cache!(new_file)
    file = Imagekit::CarrierWave::createRawOrPreloaded(new_file)
    if file
      @file = file
      @stored_version = @file.version
      @public_id = @stored_public_id = @file.public_id
      self.original_filename = sanitize(@file.original_filename)
      @cache_id = "unused" # must not be blank 
    else
      super
      @public_id = nil # allow overriding public_id
    end
  end
  
  def cache_name
    return (@file.is_a?(PreloadedImagekitFile) || @file.is_a?(StoredFile)) ? @file.to_s : super
  end
  
  class PreloadedImagekitFile < Imagekit::PreloadedFile
    def initialize(file_info)
      super
      if !valid?
        raise CarrierWave::IntegrityError, I18n.translate(:"errors.messages.imagekit_signature_error", :public_id=>public_id, :default=>"Invalid signature for #{public_id}")
      end
    end    

    def delete
      # Do nothing. This is a virtual file.
    end
    
    def original_filename
      self.filename
    end
  end
  
  class StoredFile < Imagekit::PreloadedFile
    def initialize(file_info)
      if file_info.match(STORED_IMAGKIT_PATH)
        @resource_type, @type, @version, @filename = file_info.scan(STORED_IMAGKIT_PATH).first 
      elsif file_info.match(SHORT_STORED_IMAGKIT_PATH)
        @version, @filename = file_info.scan(SHORT_STORED_IMAGKIT_PATH).first
      else
        raise(ArgumentError, "File #{file_info} is illegal") 
      end
      @public_id, @format = Imagekit::PreloadedFile.split_format(@filename)
    end
  
    def valid?
      true
    end

    def delete
      # Do nothing. This is a virtual file.
    end

    def original_filename
      self.filename
    end
    
    def to_s
      identifier
    end
  end
  
  def self.createRawOrPreloaded(file)
    return file if file.is_a?(Imagekit::CarrierWave::StoredFile)
    return PreloadedImagekitFile.new(file) if file.is_a?(String) && file.match(PRELOADED_IMAGEKIT_PATH)
    nil
  end
end
