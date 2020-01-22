# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "imagekit/version"

Gem::Specification.new do |spec|
  spec.name          = "imagekit"
  spec.version       = Imagekit::VERSION
  spec.authors       = ["Shoaib Malik"]
  spec.email         = ["shoaib2109@gmail.com"]

  spec.summary       = %q{Instant image optimization on all platforms.}
  spec.description   = %q{Intelligent real time image optimization, resizing, cropping and super fast delivery.}
  spec.homepage      = "https://imagekit.io/"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.required_ruby_version = '>= 2.2'

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_dependency "rest-client"
  
end
