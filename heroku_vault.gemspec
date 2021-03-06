# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "heroku_vault/version"

Gem::Specification.new do |spec|
  spec.name          = "heroku_vault"
  spec.version       = HerokuVault::VERSION
  spec.authors       = ["nasum"]
  spec.email         = ["tomato.wonder.life@gmail.com"]

  spec.summary       = %q{heroku config encrypt}
  spec.description   = %q{heroku config encrypt}
  spec.homepage      = "https://github.com/nasum/heroku_vault"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activesupport", "~> 5.2.0"
  spec.add_runtime_dependency "platform-api", "~> 2.1.0"
  spec.add_runtime_dependency "thor", "~> 0.20.0"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "rspec", "~> 3.7"
end
