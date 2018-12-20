# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "json_logger/version"

Gem::Specification.new do |spec|
  spec.name          = "json_logger"
  spec.version       = JsonLogger::VERSION
  spec.authors       = ["Nikolay Markov", "Gabriel Haba"]
  spec.email         = ["gabriel@apptweak.com"]

  spec.summary       = %q{Ruby JSON Logger}
  spec.homepage      = "https://github.com/apptweak/json_logger"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.10"
  spec.add_development_dependency "timecop", "~> 0.9"

  spec.add_runtime_dependency "binding_of_caller"
end
