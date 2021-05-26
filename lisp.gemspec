# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lisp/version'

Gem::Specification.new do |spec|
  spec.name          = "lisp"
  spec.version       = Lisp::VERSION
  spec.authors       = ["James Moriarty"]
  spec.email         = ["jamespaulmoriarty@gmail.com"]
  spec.summary       = %q{Lisp interpreter}
  spec.description   = "Minimal Lisp interpreter using 75LOC and only standard libraries excluding the REPL. Inspired by Lis.py."
  spec.homepage      = "https://github.com/jamesmoriarty/lisp"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "coolline"
  spec.add_dependency "coderay"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest", "> 5"
end
