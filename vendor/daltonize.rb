require 'rubygems'
require 'vips'

def deuteranope
  # we need rows to sum to 1 in Bradford space, so the matrix was normalized
  # (each value divided by the sum of the values in a row)
  [[1, 0, 0],
   [0.2836, 0.0, 0.7164],
   [0, 0, 1]]
end

def protanope
  [[0, 4.0277, -5.0277],
   [0, 1, 0],
   [0, 0, 1]]
end

def tritanope
  [[1, 0, 0],
   [0, 1, 0],
   [-0.977, 1.977, 0.0]]
end

def get_matrix (prefix)
  matrix = case prefix
    when "d" then deuteranope
    when "p" then protanope
    when "t" then tritanope
    else nil
  end
end

def daltonize (image, matrix)

  # remove any alpha channel before processing
  alpha = nil
  if image.bands == 4
      alpha = image.extract_band(3)
      image = image.extract_band(0, 3)
  end

  begin
      # import to CIELAB with lcms
      # if there's no profile there, we'll fall back to the thing below
      lab = image.icc_import_embedded(:relative)
      xyz = lab.lab_to_xyz()
  rescue VIPS::Error
      # nope .. use the built-in converter instead
      xyz = image.srgb_to_xyz()
  end

  # and now to bradford cone space (a variant of LMS)
  brad = xyz.recomb([[0.8951,  0.2664, -0.1614],
                     [-0.7502,  1.7135,  0.0367],
                     [0.0389, -0.0685,  1.0296]])

  # through the provided daltonize matrix
  mat = brad.recomb(matrix)

  # back to xyz (this is the inverse of the brad matrix above)
  xyz = mat.recomb([[0.987, -0.147, 0.16],
                     [0.432, 0.5184, 0.0493],
                     [-0.0085, 0.04, 0.968]])
  # and now to bradford cone space (a variant of LMS)
  brad = xyz.recomb([[0.8951,  0.2664, -0.1614],
                     [-0.7502,  1.7135,  0.0367],
                     [0.0389, -0.0685,  1.0296]])

  # through the provided daltonize matrix
  mat = brad.recomb(matrix)

  # back to xyz (this is the inverse of the brad matrix above)
  xyz = mat.recomb([[0.987, -0.147, 0.16],
                     [0.432, 0.5184, 0.0493],
                     [-0.0085, 0.04, 0.968]])

  # .. and back to sRGB
  rgb = xyz.xyz_to_srgb()

  # so this is the colour error
  err = image - rgb

  # add the error back to other channels to make a compensated image
  image = image + err.recomb([[0, 0, 0],
                              [0.7, 1, 0],
                              [0.7, 0, 1]])

  # reattach any alpha we saved above
  if alpha
    # image = image.bandjoin(alpha)
    image = image.bandjoin(alpha.clip2fmt(image.band_fmt))
  end
  image
end

if __FILE__ == $0
  if ARGV.length != 3
    puts "Calling syntax: daltonize.rb [fullpath to image file] [target image full path] [deficit (d=deuteranop, p=protanope, t=tritanope)]"
    puts "Example: daltonize.rb /path/to/pic.png /path/to/deuteranope.png d"
    exit 1
  end

  matrix = get_matrix(ARGV[2])
  if matrix.nil?
    puts "color-deficiency must be either d,t or p"
    exit 1
  end

  image = VIPS::Image.new(ARGV[0])
  image = daltonize(image, matrix)
  image.write(ARGV[1])
end
