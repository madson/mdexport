Gem::Specification.new do |s|
  s.name        = 'mdexport'
  s.version     = '0.0.6'
  s.date        = '2015-07-06'
  s.summary     = "mdexport is a gem that exports markdown files into html files."
  s.description = "A simple gem that exports all markdown files from current folder to html files."
  s.authors     = ["Madson Cardoso"]
  s.email       = 'madsonmac@gmail.com'
  s.files       = Dir["lib/*"]
  s.homepage    = 'http://github.com/madson/mdexport'
  s.license     = 'MIT'
  s.executables << 'mdexport'
  
  s.add_dependency 'filewatcher', '~> 0.5.1'
  s.add_dependency 'github-markdown', '~> 0.6.8'
  s.add_runtime_dependency 'commander', '~> 4.3', '>= 4.3.4'
  s.add_runtime_dependency 'mustache', '~> 1.0', '>= 1.0.2'
  s.add_development_dependency 'rspec', '~> 3.3', '>= 3.3.0'
end

