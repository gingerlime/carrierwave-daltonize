require "carrierwave-daltonize/version"

require 'vips'
require 'carrierwave/vips'

module CarrierWave
  module Daltonize

    include CarrierWave::Vips

    def self.included(base)
      base.send(:extend, ClassMethods)
    end

    module ClassMethods

      def deuteranope
        process :deuteranope
      end

      def protanope
        process :protanope
      end

      def tritanope
        process :tritanope
      end

    end

    def daltonize (simulate, distribute)
      manipulate! do |image|
        begin
            # import to CIELAB with lcms
            # if there's no profile there, we'll fall back to the thing below
            cielab = image.icc_import_embedded(:relative)
            xyz = cielab.lab_to_xyz()
        rescue VIPS::Error
            # nope .. use the built-in converter instead
            xyz = image.srgb_to_xyz()
            cielab = xyz.xyz_to_lab()
        end

        # to bradford cone space (a variant of LMS)
        brad = xyz.recomb([[0.8951,  0.2664, -0.1614],
                           [-0.7502,  1.7135,  0.0367],
                           [0.0389, -0.0685,  1.0296]])

        # through the color-vision deficit matrix
        simu = brad.recomb(simulate)

        # back to xyz (this is the inverse of the brad matrix above)
        xyz2 = simu.recomb([[0.987, -0.147, 0.16],
                           [0.432, 0.5184, 0.0493],
                           [-0.0085, 0.04, 0.968]])


        # now find the error in CIELAB
        cielab2 = xyz2.xyz_to_lab()
        err = cielab - cielab2

        # add the error channels back to the original, recombined so as to hit
        # channels the person is sensitive to
        cielab = cielab + err.recomb(distribute)

        # .. and back to sRGB 
        rgb = cielab.lab_to_xyz().xyz_to_srgb()
      end
    end

    def deuteranope
      # deuteranopes are missing green receptors, so to simulate their vision 
      # we replace the green signal with a 70/30 mix of red and blue
      # to correct, we put 50% of the red/green error into lightness and 100%
      # into yellow/blue
      daltonize([[  1,   0,   0],
                 [0.7,   0, 0.3],
                 [  0,   0,   1]], 
                [[  1, 0.5,   0],
                 [  0,   0,   0],
                 [  0,   1,   1]])
    end

    def protanope
      # protanopes are missing red receptors --- we simulate their condition by
      # replacing the red signal with an 80/20 mix of green and blue (since 
      # blue is far less important than green)
      # correction as for deuts
      daltonize([[  0, 0.8, 0.2],
                 [  0,   1,   0],
                 [  0,   0,   1]], 
                [[  1, 0.5,   0],
                 [  0,   0,   0],
                 [  0,   1,   1]])
    end

    def tritanope
      # tritanopes are missing blue receptors --- we replace the blue signal
      # with 30/70 red/green
      # to correct, we put 50% of the yellow/blue error into lightness, and 
      # 100% into red/green
      daltonize([[  1,   0,   0],
                 [  0,   1,   0],
                 [0.3, 0.7,   0]], 
                [[  1,   0, 0.5],
                 [  0,   0,   1],
                 [  0,   0,   0]])
    end
  end
end
