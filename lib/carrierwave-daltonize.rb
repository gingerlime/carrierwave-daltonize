require "carrierwave-daltonize/version"
require "daltonize"

module CarrierWave
  module Daltonize

    def self.included(base)
      base.send(:extend, ClassMethods)
    end

    module ClassMethods

      def daltonize(proc_type) 
        process :daltonize => proc_type
      end

    end

    # daltonize an image file for carrierwave
    # proc_type - the processing type (deuteranope, protanope or tritanope)
    def daltonize(proc_type)
      cache_stored_file! unless cached?
      tmp_name = current_path.sub(/(\.[a-z]+)$/i, '_tmp\1')

      ::Daltonize.daltonize_file(current_path, tmp_name, proc_type)

      FileUtils.mv(tmp_name, current_path)
    rescue => e
      raise CarrierWave::ProcessingError.new("Failed to manipulate file. Original Error: #{e}")
    end

  end
end
