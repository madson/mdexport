require 'pathname'

class String
  def filename
    File.basename(self)
  end
  
  def extension
    File.extname(self)
  end
  
  def basename
    File.basename(self, extension)
  end
  
  def html_file_path
    dirname = Pathname.new(self).dirname
    filename = self.filename.gsub(extension, '.html')
    "#{dirname}/#{filename}"
  end
end
