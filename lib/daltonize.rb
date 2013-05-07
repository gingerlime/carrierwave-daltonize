#!/usr/bin/env ruby

# run the carrierwave-daltonize filter from the command-line
# or include it in other ruby programs, e.g.
#
# ::Daltonize.daltonize_file(source, destination, :deuteranope)
#
# - or -
#
# im = VIPS::Image.new(source)
# im = ::Daltonize.tritanope(im)
# im.write(destination)

require 'matrix'
require 'rubygems'
require 'vips'

# D65 to E and back 
D652E = Matrix.diagonal(100 / 95.047, 100 / 100, 100 / 108.883)
E2D65 = D652E ** -1

# Take CIE XYZ to Bradford cone space (a variant of LMS)
# See http://en.wikipedia.org/wiki/LMS_color_space#CMCCAT97
XYZ2BRAD = Matrix[[0.8951,  0.2664, -0.1614],
                      [-0.7502,  1.7135,  0.0367],
                      [0.0389, -0.0685,  1.0296]]
BRAD2XYZ = XYZ2BRAD ** -1

module Daltonize

  def self.daltonize (image, simulate, distribute)
      # remove any alpha channel before processing
      alpha = nil
      if image.bands == 4
          alpha = image.extract_band(3)
          image = image.extract_band(0, 3)
      end

      begin
          # import to CIELAB with lcms
          # if there's no profile there, we'll fall back to the thing below
          cielab = image.icc_import_embedded(:relative)
          xyz = cielab.lab_to_xyz()
      rescue VIPS::Error
          # nope .. use the built-in srgb converter instead
          xyz = image.srgb_to_xyz()
          cielab = xyz.xyz_to_lab()
      end

      # pre-multiply our colour matrix
      #
      # reading right to left, we want to take our D65 XYZ to E, then to 
      # Bradford cone space, then through the simulation matrix, then back 
      # to XYZ, then back to D65
      #
      # we need to use E because we will be juggling the colour channels and we
      # want them all to have the same range so as not to disturb the neutral
      # axis
      m = E2D65 * BRAD2XYZ * Matrix.rows(simulate) * XYZ2BRAD * D652E

      # simulate colour-blindness
      xyz2 = xyz.recomb(m.to_a())

      # now find the error in CIELAB
      cielab2 = xyz2.xyz_to_lab()
      err = cielab - cielab2

      # add the error channels back to the original, recombined so as to hit
      # channels the person is sensitive to
      cielab = cielab + err.recomb(distribute)

      # .. and back to sRGB 
      image = cielab.lab_to_xyz().xyz_to_srgb()

      # reattach any alpha we saved above
      if alpha
        image = image.bandjoin(alpha.clip2fmt(image.band_fmt))
      end

      return image
  end

  def self.deuteranope(image)
    # deuteranopes are missing green receptors, so to simulate their vision 
    # we replace the green signal with a 70/30 mix of red and blue
    #
    # to compensate, we put 50% of the red/green error into lightness and 100%
    # into yellow/blue
    self.daltonize(image,
              [[  1,   0,   0],
               [0.7,   0, 0.3],
               [  0,   0,   1]], 
              [[  1, 0.5,   0],
               [  0,   0,   0],
               [  0,   1,   1]])
  end

  def self.protanope(image)
    # protanopes are missing red receptors --- we simulate their condition by
    # replacing the red signal with an 80/20 mix of green and blue (since 
    # blue is far less important than green)
    #
    # compensate as for deuts
    self.daltonize(image,
              [[  0, 0.8, 0.2],
               [  0,   1,   0],
               [  0,   0,   1]], 
              [[  1, 0.5,   0],
               [  0,   0,   0],
               [  0,   1,   1]])
  end

  def self.tritanope(image)
    # tritanopes are missing blue receptors --- we replace the blue signal
    # with 30/70 red/green
    #
    # to compensate, we put 50% of the yellow/blue error into lightness, and 
    # 100% into red/green
    self.daltonize(image,
              [[  1,   0,   0],
               [  0,   1,   0],
               [0.3, 0.7,   0]], 
              [[  1,   0, 0.5],
               [  0,   0,   1],
               [  0,   0,   0]])
  end

  def self.daltonize_file(source, destination, type)
    im = VIPS::Image.new(source)
    im = self.send(type.to_sym, im)
    im.write(destination)
  end

end

types = [:deuteranope, :protanope, :tritanope]

if __FILE__ == $0
  if ARGV.length != 3
      puts "usage: daltonize INFILE OUTFILE TYPE"
      puts "where TYPE is one of #{types.join(', ')}"
      exit 1
  end

  unless types.include?(ARGV[2].to_sym)
    puts "#{ARGV[2]} is not one of #{types.join(', ')}"
    exit 1
  end

  Daltonize.daltonize_file(ARGV[0], ARGV[1], ARGV[2])

end
