#!/usr/bin/env python
# -*- coding: iso-8859-1 -*-
"""
   Modified by Yoav Aner for CarrierWave-Daltonize gem

   MoinMoin - Daltonize ImageCorrection - Effect

   Daltonize image correction algorithm implemented according to
   http://scien.stanford.edu/class/psych221/projects/05/ofidaner/colorblindness_project.htm

   Many thanks to Onur Fidaner, Poliang Lin and Nevran Ozguven for their work
   on this topic and for releasing their complete research results to the public
   (unlike the guys from http://www.vischeck.com/). This is of great help for a
   lot of people!

   Please note:
   Daltonize ImageCorrection needs
   * Python Image Library (PIL) from http://www.pythonware.com/products/pil/
   * NumPy from http://numpy.scipy.org/

   You can call Daltonize from the command-line with
   "daltonize.py C:\image.png"

   Explanations:
       * Normally this module is called from Moin.AttachFile.get_file
       * @param filename, fpath is the filename/fullpath to an image in the attachment
         dir of a page. 
       * @param color_deficit can either be
           - 'd' for Deuteranope image correction
           - 'p' for Protanope image correction
           - 't' for Tritanope image correct
   Idea:
       * Since daltonizing an image takes quite some time and we don't want visually
         impaired users to wait so long until the page is loaded, this module has a
         command-line option built-in which could be called as a separate process
         after a file upload of a non visually impaired user in "AttachFile", e.g
         "spawnlp(os.NO_WAIT...)"
       * "AttachFile": If an image attachment is deleted or overwritten by a new version
         please make sure to delete the daltonized images and redaltonize them.
       * But all in all: Concrete implementation of ImageCorrection needs further
         thinking and discussion. This is only a first prototype as proof of concept.

   @copyright: 2007 by Oliver Siemoneit
   @license: GNU GPL, see COPYING for details.
"""

import os.path

def execute(source_filename, dest_filename, color_deficit):

    try:
        import numpy
        from PIL import Image
    except Exception, e:
        print "%s. Please install numpy and PIL, e.g. using `pip install PIL`" % e
        sys.exit(1)

    # Get image data
    im = Image.open(source_filename)
    if im.mode in ['1', 'L']: # Don't process black/white or grayscale images
        return source_filename
    im = im.copy() 
    im = im.convert('RGB') 
    RGB = numpy.asarray(im, dtype=float)

    # Transformation matrix for Deuteranope (a form of red/green color deficit)
    lms2lmsd = numpy.array([[1,0,0],[0.494207,0,1.24827],[0,0,1]])
    # Transformation matrix for Protanope (another form of red/green color deficit)
    lms2lmsp = numpy.array([[0,2.02344,-2.52581],[0,1,0],[0,0,1]])
    # Transformation matrix for Tritanope (a blue/yellow deficit - very rare)
    lms2lmst = numpy.array([[1,0,0],[0,1,0],[-0.395913,0.801109,0]])
    # Colorspace transformation matrices
    rgb2lms = numpy.array([[17.8824,43.5161,4.11935],[3.45565,27.1554,3.86714],[0.0299566,0.184309,1.46709]])
    lms2rgb = numpy.linalg.inv(rgb2lms)
    # Daltonize image correction matrix
    err2mod = numpy.array([[0,0,0],[0.7,1,0],[0.7,0,1]])

    # Get the requested image correction
    if color_deficit == 'd':
        lms2lms_deficit = lms2lmsd
    elif color_deficit == 'p':
        lms2lms_deficit = lms2lmsp
    elif color_deficit == 't':
        lms2lms_deficit = lms2lmst
    else:
        return (filename, fpath)
    
    # Transform to LMS space
    LMS = numpy.zeros_like(RGB)               
    for i in range(RGB.shape[0]):
        for j in range(RGB.shape[1]):
            rgb = RGB[i,j,:3]
            LMS[i,j,:3] = numpy.dot(rgb2lms, rgb)

    # Calculate image as seen by the color blind
    _LMS = numpy.zeros_like(RGB)  
    for i in range(RGB.shape[0]):
        for j in range(RGB.shape[1]):
            lms = LMS[i,j,:3]
            _LMS[i,j,:3] = numpy.dot(lms2lms_deficit, lms)

    _RGB = numpy.zeros_like(RGB) 
    for i in range(RGB.shape[0]):
        for j in range(RGB.shape[1]):
            _lms = _LMS[i,j,:3]
            _RGB[i,j,:3] = numpy.dot(lms2rgb, _lms)

##    # Save simulation how image is perceived by a color blind
##    for i in range(RGB.shape[0]):
##        for j in range(RGB.shape[1]):
##            _RGB[i,j,0] = max(0, _RGB[i,j,0])
##            _RGB[i,j,0] = min(255, _RGB[i,j,0])
##            _RGB[i,j,1] = max(0, _RGB[i,j,1])
##            _RGB[i,j,1] = min(255, _RGB[i,j,1])
##            _RGB[i,j,2] = max(0, _RGB[i,j,2])
##            _RGB[i,j,2] = min(255, _RGB[i,j,2])
##    simulation = _RGB.astype('uint8')
##    im_simulation = Image.fromarray(simulation, mode='RGB')
##    simulation_filename = "%s-%s-%s" % ('daltonize-simulation', color_deficit, filename)
##    simulation_fpath = os.path.join(head, simulation_filename)
##    im_simulation.save(simulation_fpath)

    # Calculate error between images
    error = (RGB-_RGB)

    # Daltonize
    ERR = numpy.zeros_like(RGB) 
    for i in range(RGB.shape[0]):
        for j in range(RGB.shape[1]):
            err = error[i,j,:3]
            ERR[i,j,:3] = numpy.dot(err2mod, err)

    dtpn = ERR + RGB
    
    for i in range(RGB.shape[0]):
        for j in range(RGB.shape[1]):
            dtpn[i,j,0] = max(0, dtpn[i,j,0])
            dtpn[i,j,0] = min(255, dtpn[i,j,0])
            dtpn[i,j,1] = max(0, dtpn[i,j,1])
            dtpn[i,j,1] = min(255, dtpn[i,j,1])
            dtpn[i,j,2] = max(0, dtpn[i,j,2])
            dtpn[i,j,2] = min(255, dtpn[i,j,2])

    result = dtpn.astype('uint8')
    
    # Save daltonized image
    im_converted = Image.fromarray(result, mode='RGB')
    im_converted.save(dest_filename)
    return dest_filename


if __name__ == '__main__':
    import sys
    if len(sys.argv) != 4:
        print "Calling syntax: daltonize.py [fullpath to image file] [target image full path] [deficit (d=deuteranop, p=protanope, t=tritanope)]"
        print "Example: daltonize.py /path/to/pic.png d /path/to/deuteranope.png"
        sys.exit(1)

    source_filename = sys.argv[1]
    dest_path = sys.argv[2]
    color_deficit = sys.argv[3]

    if not (os.path.isfile(source_filename)):
        print "Given file does not exist"
        sys.exit(1)

    extpos = source_filename.rfind(".")
    if not (extpos > 0 and source_filename[extpos:].lower() in ['.gif', '.jpg', '.jpeg', '.png', '.bmp', '.ico', ]):
        print "Given file is not an image"
        sys.exit(1)

    if color_deficit not in ('d', 'p', 't'):
        print "unknown deficit %s. Please use one of (d,p,t)" % color_deficit
        sys.exit(1)

    execute(source_filename, dest_path, color_deficit)
    print "Image successfully daltonized"
