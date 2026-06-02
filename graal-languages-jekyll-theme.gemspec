# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "graal-languages-jekyll-theme"
  spec.version       = "0.2.0"
  spec.authors       = ["GraalVM Development"]
  spec.email         = ["graalvm-dev@oss.oracle.com"]

  spec.summary       = "Jekyll Theme for Graal Languages"
  spec.homepage      = "https://graalvm.org"
  spec.license       = "UPL"

  spec.required_ruby_version = ">= 3.1"

  spec.add_runtime_dependency "jekyll", "~> 4.3"

  spec.files = Dir.glob("{_includes,_layouts,_plugins,assets}/**/*", File::FNM_DOTMATCH)
                  .select { |path| File.file?(path) }
                  .reject { |path| path.start_with?("assets/.") }
  spec.files += %w[LICENSE.txt README.md]

  spec.require_paths = ["_plugins"]
end
