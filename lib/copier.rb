require 'fileutils'
require 'pathname'
require_relative 'utils'

module Copier
  def self.copy_missing_and_newer(source, dest)
    source_path = Pathname.new(source)
    dest_path = Pathname.new(dest)

    coppied_files = 0
    coppied_folders = 0
    overwritten_f = 0

    Dir.glob("#{source}/**/*").each do |element|
      relative = Pathname.new(element).relative_path_from(source_path)
      dest_element = dest_path + relative

      if File.directory?(element)
        unless Dir.exist?(dest_element)
          FileUtils.mkdir_p(dest_element)
          puts " Created folder: #{dest_element}"
          coppied_folders += 1
        end
      elsif File.exist?(element)
        if !File.exist?(dest_element)
          FileUtils.cp(element, dest_element)
          puts "Coppied new file: #{element}"
          coppied_files += 1
        elsif Utils.newer?(element, dest_element)
          FileUtils.cp(element, dest_element)
          overwritten_f += 1
        end
      end
    end

    puts "\n === SUMMARY ==="
    puts "New folders: #{coppied_folders}"
    puts "New files: #{coppied_files}"
    puts "Overwritten files: #{overwritten_f}"
  end
end
