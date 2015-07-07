Gem::Specification.new do |s|
  s.name        = 'mdexport'
  s.version     = '0.0.3'
  s.date        = '2015-07-06'
  s.summary     = "mdexport is a gem that exports markdown files into html files."
  s.description = "A simple gem that exports all markdown files from current folder to html files."
  s.authors     = ["Madson Cardoso"]
  s.email       = 'madsonmac@gmail.com'
  s.files       = ["lib/mdexport.rb"]
  s.homepage    = 'http://github.com/madson/mdexport'
  s.license     = 'MIT'
  s.executables << 'mdexport'
  
  s.add_dependency 'filewatcher', '~> 0.5.1'
  s.add_dependency 'github-markdown', '~> 0.6.8'
end

