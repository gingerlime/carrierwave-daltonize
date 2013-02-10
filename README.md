# CarrierWave::Daltonize

Adds [daltonize](http://www.daltonize.org/) processing to carrierwave (using python)

## Installation

Requires python with Numpy and PIL libraries. To install run

    easy_install numpy
    easy_install PIL

or

    pip install numpy
    pip install PIL

Add this line to your application's Gemfile:

    gem 'carrierwave-daltonize', :git => 'git://github.com/gingerlime/carrierwave-daltonize.git', :branch => 'python'

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

Currently seems relatively slow, and requires launching python from a system process.

## Contributors

* Oliver Siemoneit - created the original python code for MoinMoin
* Yoav Aner (@gingerlime) - adapted the code and wrapped it into this Gem

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
