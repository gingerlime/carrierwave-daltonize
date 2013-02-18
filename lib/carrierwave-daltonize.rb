require "carrierwave-daltonize/version"
require "daltonize"

module CarrierWave
  module Daltonize

    @@_gem_path = Gem::Specification.find_by_name('carrierwave-daltonize').full_gem_path

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

    # rubytonize - daltonize processing using ruby (with vips)
    def rubytonize proc_type
      cache_stored_file! unless cached?
      tmp_name = current_path.sub(/(\.[a-z]+)$/i, '_tmp\1')

      matrices = get_matrices(proc_type)
      daltonize_file(current_path, tmp_name, matrices)

      FileUtils.mv(tmp_name, current_path)
    rescue => e
      raise CarrierWave::ProcessingError.new("Failed to manipulate file. Original Error: #{e}")
    end

    def deuteranope
      rubytonize 'd'
    end

    def protanope
      rubytonize 'p'
    end

    def tritanope
      rubytonize 't'
    end
  end
end
