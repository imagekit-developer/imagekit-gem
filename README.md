# Imagekit

Imagekit provides intelligent real time image optimization, resizing, cropping and super fast delivery.

Imagekit offers comprehensive APIs and administration capabilities and is easy to integrate with any web application, existing or new.

Imagekit provides URL and HTTP based APIs that can be easily integrated with any Web development framework. 

For Ruby on Rails, Imagekit provides a GEM for simplifying the integration even further.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'imagekit', github: 'imagekit-developer/imagekit-gem'
```

And then execute:

    $ bundle

And then run generator:

    $ rails generate imagekit:install

Or install it yourself as:

    $ gem install imagekit

## Try it right away

Sign up for a [free account](https://imagekit.io/registration) so you can try out image transformations and seamless image delivery through CDN.

## Usage

For plenty of transformation options, see our [image transformations documentation](https://docs.imagekit.io/#transformations).

### Configuration

Login to your imagekit dashboard and find the `public key`, `private key` and `imagekit id`(Imagekit id is your account id).

After executing of the gerenrator command `rails generate imagekit:install`, you will get a file named as `imagekit.rb` under `config/initializers`.

Replace the corresponding values

```
Imagekit.configure do |config|
  config.public_key     =  'E/bDwTissZtxxxxxxxxxxxxxxxxx'
  config.private_key    = 'WMXM/R+8g8Lxxxxxxxxxxxxxxxxx'
  config.imagekit_id    = 'b1wxxxxxx'
  #config.use_subdomain  = false (default false)
  #config.use_secure     = true (default true)
end

```

`If you put cname in config, then the image url transformation would be https://demo.imagekit.io`

### Embedding and transforming images

Any image uploaded to Imagekit can be transformed and embedded using powerful view helper methods:

The following example generates an image of an uploaded `default-image` image while transforming it to crop a 100x150 rectangle:

```
im_image_tag("https://ik.imagekit.io/demo/default-image.jpg", transformation: { height: 150, width: 100 })
```

With CNAME
```
im_image_tag("https://demo.imagekit.io/default-image.jpg", transformation: { height: 150, width: 100 })
```

The following example generates an image of an uploaded `default-image` image while change the image quality to 80:

```
im_image_tag("https://ik.imagekit.io/demo/default-image.jpg", transformation: { quality: 80 })
```

Here are the possible transformation options with valid values.
```
1.  height
2.  width
3.  crop (Valid values: maintain_ratio, force, at_least, at_max)
4.  quality (Valid values: 0-100)
5.  format (Valid values: auto, webp, jpg, jpeg, png)
6.  progressive_jpeg (Valid values: true, false)
7.  image_metadata (Valid Values: true, false)
8.  color_profile (Valid Values: true, false)
9.  rotate (Valid Values: 0, 90, 180, 270, 360, auto)
10. radius (Valid Values: any positive integer or “max”)
11. background (Valid Values: a valid RGB hex code Default: Black (000000))
12. blur (Valid Values: Integers from 1 to 100)
13. border (A valid value would look like b-10_FF0000. This would add a constant border of 10px with color code #FF0000 around the image. If the original image dimension is 200x200, then after applying the border, the dimensions would be 220x220.)
14. dpr (Valid Values: 0.1 to 5.0)
15. overlay_image (Valid value: any uploaded image e.g. logo-white_SJwqB4Nfe.png)
16. named_transformation
17. contrast (Valid Values: e-contrast)
18. sharpen (Valid Values: e-sharpen)
19. Focus (Valid Values: center, centre, top, left, bottom, right, top_left, top_right, bottom_left, bottom_right, auto )
```

`NOTE - You can provide the imagekit transformation options inside the transformation hash of im_image_tag`

### Upload

Assuming you have your Imagekit configuration parameters defined (`public key`, `private key`, `imagekit id`), uploading to Imagekit is very simple.
    
The following example uploads a local JPG to the imagekit: 

    Imagekit::Uploader.upload("my_picture.jpg", filename: 'my_picture')

## Imagekit with carrierwave

If you would like to use our optional integration module of image uploads with ActiveRecord or Mongoid using Imagekit, install Imagekit GEM:

    $ gem 'carrierwave'
    $ gem 'imagekit'

###### Note: `The CarrierWave GEM should be loaded before the Imagekit GEM.`.
Below we have provided quick instructions for using imagekit with CarrierWave in your Rails project.

In our example, we have the Post model entity. You can attach an image to each post. Attached images are managed by the 'picture' attribute (column) of the Post entity.

To get started, first define a CarrierWave uploader class and tell it to use the Imagekit gem. ([See CarrierWave documentation](https://github.com/carrierwaveuploader/carrierwave) for more details).

```
class PictureUploader < CarrierWave::Uploader::Base
  include Imagekit::CarrierWave
 
  # Generate a 164x164 JPG of 80% quality 
  # Possible cropping options are as following :
  # maintain_ratio -> resize_to_limit, resize_to_fill or crop
  # force          -> resize_to_fit
  # at_max         -> resize_and_pad
  # at_least       -> scale
  ## You can pass all possible transformations in the transformation hash.
  version :cropped do
    process resize_to_fill: [164, 164]
    process convert: 'jpg'
    imagekit_transformation transformation: { quality: 80, rotate: 90 }
  end
  # You can access the url like post.picture.cropped.url or post.picture.url(:cropped)


  ## You can use standalone transformation options as in the example below
  # Rotate an image to 90 degree.
  version :rotated do
    imagekit_transformation transformation: { rotate: 90 }
  end
  # You can access the url like post.picture.rotated.url or post.picture.url(:rotated)

end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/imagekit.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
