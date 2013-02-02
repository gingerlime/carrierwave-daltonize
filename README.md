# CarrierWave::Daltonize

Adds [daltonize](http://www.daltonize.org/) processing to carrierwave (using carrierwave-vips)

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

## Limitations

Currently supports only jpeg. 

## Contributors

* John Cupitt (@jcupitt) - created the ruby-vips algorithm
* Yoav Aner (@gingerlime) - wrapped the code into this Gem
* Stanislaw Pankevich (@stanislaw) and Mario Visic (@mariovisic) - creators of carrierwave-vips

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
