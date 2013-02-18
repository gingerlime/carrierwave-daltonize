require 'rubygems'
require 'vips'

def deuteranope_matrices
  # deuteranopes are missing green receptors, so to simulate their vision 
  # we replace the green signal with a 70/30 mix of red and blue
  # to correct, we put 50% of the red/green error into lightness and 100%
  # into yellow/blue
  [[[  1,   0,   0],
    [0.7,   0, 0.3],
    [  0,   0,   1]],
   [[  1, 0.5,   0],
    [  0,   0,   0],
    [  0,   1,   1]]]
end

def protanope_matrices
  # protanopes are missing red receptors --- we simulate their condition by
  # replacing the red signal with an 80/20 mix of green and blue (since 
  # blue is far less important than green)
  # correction as for deuts
  [[[  0, 0.8, 0.2],
    [  0,   1,   0],
    [  0,   0,   1]],
   [[  1, 0.5,   0],
    [  0,   0,   0],
    [  0,   1,   1]]]
end

def tritanope_matrices
  # tritanopes are missing blue receptors --- we replace the blue signal
  # with 30/70 red/green
  # to correct, we put 50% of the yellow/blue error into lightness, and 
  # 100% into red/green
  [[[  1,   0,   0],
    [  0,   1,   0],
    [0.3, 0.7,   0]], 
   [[  1,   0, 0.5],
    [  0,   0,   1],
    [  0,   0,   0]]]
end

def get_matrices (prefix)
  matrices = case prefix
    when "d" then deuteranope_matrices
    when "p" then protanope_matrices
    when "t" then tritanope_matrices
    else nil
  end
end

def daltonize (image, simulate, distribute)

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
    xyz = lab.lab_to_xyz()
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
  image = cielab.lab_to_xyz().xyz_to_srgb()

  # reattach any alpha we saved above
  if alpha
    # image = image.bandjoin(alpha)
    image = image.bandjoin(alpha.clip2fmt(image.band_fmt))
  end
  image
end

def daltonize_file(source, destination, matrices)
  image = VIPS::Image.new(source)
  image = daltonize(image, *matrices)
  image.write(destination)
end

if __FILE__ == $0
  if ARGV.length != 3
    puts "Calling syntax: daltonize.rb [fullpath to image file] [target image full path] [deficit (d=deuteranop, p=protanope, t=tritanope)]"
    puts "Example: daltonize.rb /path/to/pic.png /path/to/deuteranope.png d"
    exit 1
  end

  matrices = get_matrices(ARGV[2])
  if matrices.nil?
    puts "color-deficiency must be either d,t or p"
    exit 1
  end

  daltonize_file(ARGV[0], ARGV[1], matrices)
  # image = VIPS::Image.new(ARGV[0])
  # image = daltonize(image, *matrices)
  # image.write(ARGV[1])
end
