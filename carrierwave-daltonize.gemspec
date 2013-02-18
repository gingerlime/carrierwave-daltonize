# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'carrierwave-daltonize/version'

Gem::Specification.new do |gem|
  gem.name          = "carrierwave-daltonize"
  gem.version       = Carrierwave::Daltonize::VERSION
  gem.authors       = ["Yoav Aner"]
  gem.email         = ["yoav@gingerlime.com"]
  gem.description   = %q{Carrierwave Daltonize processing}
  gem.summary       = %q{Adds daltonize processing for converting images to help colour-blindness. Using the python implmentation}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_runtime_dependency 'ruby-vips', '>=0.2.0'

end
