# CarrierWave::Daltonize

Adds [daltonize](http://www.daltonize.org/) processing to carrierwave (using 
carrierwave-vips)

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

The directory 'other' contains a command-line version,
run with something like:

    ./daltonize.rb in.jpg out.jpg deuteranope

There's also a version of the algorithm in
[nip2](https://github.com/jcupitt/nip2) for easy testing of the
details of the parameters. Run with something like:

    nip2 daltonize.ws

This workspace needs version 7.33 or later of nip2.

## Contributors

* John Cupitt (@jcupitt) - created the ruby-vips algorithm
* Yoav Aner (@gingerlime) - wrapped the code into this Gem
* Jeremy Nicoll (@eltiare), Stanislaw Pankevich (@stanislaw) and Mario Visic (@mariovisic) - creators / contributors of carrierwave-vips

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
