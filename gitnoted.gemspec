
Gem::Specification.new do |gem|
  gem.name        = "git-notes"
  gem.description = "A simple document server that works with Github Wiki or Gollum to serve foot notes for external websites just by adding a small script tag."
  gem.homepage    = "https://github.com/frsyuki/gitnoted"
  gem.summary     = gem.description
  gem.version     = "0.1.0"
  gem.authors     = ["Sadayuki Furuhashi"]
  gem.email       = ["frsyuki@gmail.com"]
  gem.license     = "MIT"
  gem.has_rdoc    = false
  gem.files       = `git ls-files`.split("\n")
  gem.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ['lib']

  gem.add_dependency 'sinatra', '~> 1.4'
  gem.add_dependency 'puma', '~> 3.7'
  gem.add_dependency 'rack-cors', '~> 0.4'
  gem.add_dependency 'redcarpet', '~> 3.4'
  gem.add_dependency 'rugged', '~>  0.25'
  gem.add_dependency 'concurrent-ruby', '>= 1.0.5'
  gem.add_dependency 'sigdump', '>= 0.2.4'
  gem.add_development_dependency "rake", ">= 0.9.2"
end
