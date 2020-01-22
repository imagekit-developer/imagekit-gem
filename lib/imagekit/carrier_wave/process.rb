module Imagekit::CarrierWave
  module ClassMethods
    def make_private
      self.storage_type = :private
    end

    def process_all_versions(*args)
      @all_versions ||= Class.new(self)
      @all_versions.process(*args)
    end

    def eager
      process :eager => true
    end

    def convert(format)
      process :convert => format
    end

    def resize_to_limit(width, height)
      process :resize_to_limit => [width, height]
    end

    def resize_to_fit(width, height, crop='fit')
      process :resize_to_fit => [width, height, crop]
    end

    def resize_to_fill(width, height, crop="maintain_ratio")
      process :resize_to_fill => [width, height, crop]
    end

    def resize_and_pad(width, height, crop="at_max")
      process :resize_and_pad => [width, height, crop]
    end

    def scale(width, height, crop="at_least")
      process :scale => [width, height, crop]
    end

    def crop(width, height, crop="maintain_ratio")
      process :crop => [width, height, crop]
    end

    def imagekit_transformation(options)
      process imagekit_transformation: options[:transformation]
    end

    def tags(*tags)
      process tags: tags
    end
  end

  def set_or_yell(hash, attr, value)
    raise Imagekit::ImagekitException, "conflicting transformation on #{attr} #{value}!=#{hash[attr]}" if hash[attr] && hash[attr] != value
    hash[attr] = value
  end

  def transformation
    return @transformation if @transformation
    @transformation = {}

    self.all_processors.each do |name, args, condition|

      if(condition)
        if condition.respond_to?(:call)
          next unless condition.call(self, :args => args)
        else
          next unless self.send(condition)
        end
      end

      case name
      when :convert
        set_or_yell(@transformation, :format, args)
      when :resize_to_limit
        set_or_yell(@transformation, :width, args[0])
        set_or_yell(@transformation, :height, args[1])
        set_or_yell(@transformation, :crop, :maintain_ratio)
      when :resize_to_fit
        set_or_yell(@transformation, :width, args[0])
        set_or_yell(@transformation, :height, args[1])
        set_or_yell(@transformation, :crop, :force)
      when :resize_to_fill
        set_or_yell(@transformation, :width, args[0])
        set_or_yell(@transformation, :height, args[1])
        set_or_yell(@transformation, :crop, :maintain_ratio)
      when :resize_and_pad
        set_or_yell(@transformation, :width, args[0])
        set_or_yell(@transformation, :height, args[1])
        set_or_yell(@transformation, :crop, :at_max)
      when :scale
        set_or_yell(@transformation, :width, args[0])
        set_or_yell(@transformation, :height, args[1])
        set_or_yell(@transformation, :crop, :at_least)
      when :crop
        set_or_yell(@transformation, :width, args[0])
        set_or_yell(@transformation, :height, args[1])
        set_or_yell(@transformation, :crop, :maintain_ratio)
      when :imagekit_transformation
        args.each do
          |attr, value|
          set_or_yell(@transformation, attr, value)
        end
      else
        if args.blank?
          Array(send(name)).each do
            |attr, value|
            set_or_yell(@transformation, attr, value)
          end
        end
      end
    end
    @transformation
  end

  def all_versions_processors
    all_versions = self.class.instance_variable_get('@all_versions')

    all_versions ? all_versions.processors : []
  end

  def all_processors
    (self.is_main_uploader? ? [] : all_versions_processors) + self.class.processors
  end

  def eager
    @eager ||= self.all_processors.any?{|processor| processor[0] == :eager}
  end

  def tags
    @tags ||= self.all_processors.select{|processor| processor[0] == :tags}.map(&:second).first
    raise Imagekit::ImagekitException, "tags cannot be used in versions." if @tags.present? && self.version_name.present?
    @tags
  end

  def requested_format
    format_processor = self.all_processors.find{|processor| processor[0] == :convert}
    if format_processor
      # Explicit format is given
      format = Array(format_processor[1]).first
    elsif self.transformation.include?(:format)
      format = self.transformation[:format]
    elsif self.version_name.present?
      # No local format. The reset should be handled by main uploader
      uploader = self.model.send(self.mounted_as)
      format = uploader.format
    end
    format
  end

  def format
    format = Imagekit::PreloadedFile.split_format(original_filename || "").last
    return format || "" if resource_type == "raw"
    format = requested_format || format || default_format
 
    format = format.to_s.downcase
    supported_formats = {
      "jpeg" => "jpg",
      "jpe"  => "jpg",
      "tif"  => "tiff",
      "ps"   => "eps",
      "ept"  => "eps"
    }
    supported_formats[format] || format
  end
end
