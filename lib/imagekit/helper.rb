require 'digest/md5'

module ImagekitHelper

  def im_image_tag(source, options = {})
    imagekit_tag source, options do |source, options|
      if source
        image_tag(source)
      else
        tag 'img', options
      end
    end
  end

  def imagekit_tag(source, options = {})
    tag_options = options.clone
    source = imagekit_url_internal(source, options)
    if block_given?
      yield(source, tag_options)
    else
      tag('div', tag_options)
    end
  end

  private

    def imagekit_url_internal(source, options)
      return source unless options[:transformation].present?
      image_name = source.match( /[-_\w:]+\.(jpe?g|png|gif)$/i).to_s
      source.slice!(image_name)
      array = []
      options[:transformation].each do |k, v|
        key = Imagekit::Utils::PREDEFINED_TRANSFORMATION[k.to_s]
        array << "#{key}-#{v}"
      end
      transformation_string = array.size > 0 ? "tr:#{array.join(',')}" : nil
      source = if transformation_string
        "#{source}#{transformation_string}/#{image_name}"
      else
        "#{source}/#{image_name}"
      end
    end

end

if defined?(::Rails::VERSION::MAJOR) && ::Rails::VERSION::MAJOR == 2
  ActionView::Base.send :include, ActionView::Helpers::AssetTagHelper
  ActionView::Base.send :include, ImagekitHelper
end
