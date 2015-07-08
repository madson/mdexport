require 'fileutils'

class File
  
  def self.remove(path)
    FileUtils.rm(path) if File.exist?(path)
  end
  
end