# CarrierWave::Daltonize

Adds [daltonize](http://www.daltonize.org/) processing to carrierwave (using ruby-vips)

## Installation

Requires ruby-vips. See https://github.com/jcupitt/ruby-vips

Add this line to your application's Gemfile:

    gem 'carrierwave-daltonize', :git => 'git://github.com/gingerlime/carrierwave-daltonize.git', :branch => 'ruby'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install carrierwave-daltonize

## Usage

In your carrierwave uploader, include carrierwave daltonize, and then use
any of the daltonize processing functions.

    class ColourBlindUploader < CarrierWave::Uploader::Base
      include CarrierWave::Daltonize

      version :deut
        process :deuteranope
      end

      version :prot
        process :protanope
      end

      version :trit
        process :tritanope
      end
    end

### Standalone

You can also use the ruby code without carrierwave to process an image file.

Usage:
    
    ruby lib/daltonize.rb [fullpath to image file] [target image full path] [deficit (d=deuteranop, p=protanope, t=tritanope)]

## Limitations

Needs more testing by colour-blind people with specific deficiencies.

## Contributors

* John Cupitt (@jcupitt) - created the ruby-vips algorithm and greatly improved the python/javascript implementations
* Oliver Siemoneit - created the original python code for MoinMoin
* Yoav Aner (@gingerlime) - adapted the code and wrapped it into this Gem

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
