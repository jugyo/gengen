# -*- encoding: utf-8 -*-
require File.expand_path('../lib/gengen/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["jugyo"]
  gem.email         = ["jugyo.org@gmail.com"]
  gem.description   = %q{A simple generator using github repository}
  gem.summary       = %q{A simple generator}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "gengen"
  gem.require_paths = ["lib"]
  gem.version       = Gengen::VERSION

  gem.add_development_dependency "rake"
  gem.add_development_dependency "rspec", "~> 2.0"
  gem.add_development_dependency "rr"
end
