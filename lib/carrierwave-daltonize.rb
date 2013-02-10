require "carrierwave-daltonize/version"

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

    # pytonize - daltonize processing using python
    def pytonize proc_type
      cache_stored_file! unless cached?
      tmp_name = current_path.sub(/(\.[a-z]+)$/i, '_tmp\1')
      output = `python #{@@_gem_path}/vendor/daltonize.py #{current_path} #{tmp_name} #{proc_type}`
      raise output if $?.exitstatus != 0
      FileUtils.mv(tmp_name, current_path)
    rescue => e
      raise CarrierWave::ProcessingError.new("Failed to manipulate file. Original Error: #{e}")
    end

    def deuteranope
      pytonize 'd'
    end

    def protanope
      pytonize 'p'
    end

    def tritanope
      pytonize 't'
    end
  end
end
