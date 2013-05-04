# CarrierWave::Daltonize

Adds [daltonize](http://www.daltonize.org/) processing to carrierwave (using ruby-vips).

## Installation

Requires ruby-vips. See https://github.com/jcupitt/ruby-vips

Add this line to your application's Gemfile:

    gem 'carrierwave-daltonize', :git => 'git://github.com/gingerlime/carrierwave-daltonize.git'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install carrierwave-daltonize

## Usage

In your carrierwave uploader, include carrierwave daltonize, and then use
any of the daltonize processing functions.

    class ColourBlindUploader < CarrierWave::Uploader::Base
      include CarrierWave::Daltonize

      version :deuteranope
        process :daltonize => :deuteranope
      end

      version :protanope
        process :daltonize => :protanope
      end

      version :tritanope
        process :daltonize => :tritanope
      end
    end

### Standalone

You can also use the ruby code without carrierwave to process an image file.

Usage:
    
    ./lib/daltonize.rb in.jpg out.jpg deuteranope

There's also a version of the algorithm in
[nip2](https://github.com/jcupitt/nip2) for easy testing of the
details of the parameters. See 'other' directory. Run with something like:

    nip2 daltonize.ws

This workspace needs version 7.33 or later of nip2.

## CarrierWave::VIPS

Note that CarrierWave::Daltonize no longer relies on [CarrierWave::VIPS](https://github.com/eltiare/carrierwave-vips).
However, since you already need ruby-vips to run this, it would make sense to use it too. 

CarrierWave::VIPS should dramatically increase the speed and reduce memory footprint
of your carrierwave image processing.

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
