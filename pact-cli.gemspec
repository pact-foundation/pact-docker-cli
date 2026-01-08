
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "pact/cli/version"

def gem_files
  if Dir.exist?(".git")
    `git ls-files`.split($/)
  else
    root_path      = File.dirname(__FILE__)
    all_files      = Dir.chdir(root_path) { Dir.glob("**/{*,.*}") }
    all_files.reject! { |file| [".", ".."].include?(File.basename(file)) || File.directory?(file)}
    gitignore_path = File.join(root_path, ".gitignore")
    gitignore      = File.exist?(gitignore_path) ? File.readlines(gitignore_path) : []
    gitignore.map!    { |line| line.chomp.strip }
    gitignore.reject! { |line| line.empty? || line =~ /^(#|!)/ }

    all_files.reject do |file|
      gitignore.any? do |ignore|
        file.start_with?(ignore) ||
          File.fnmatch(ignore, file, File::FNM_PATHNAME) ||
          File.fnmatch(ignore, File.basename(file), File::FNM_PATHNAME)
      end
    end
  end
end


Gem::Specification.new do |spec|
  spec.name          = "pact-cli"
  spec.version       = Pact::Cli::VERSION
  spec.authors       = ["Beth Skurrie"]
  spec.email         = ["beth@bethesque.com"]

  spec.summary       = %q{Amalgamated pact CLI}
  spec.homepage      = "https://pact.io"
  spec.license       = "MIT"

  spec.files         = gem_files
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "pact-mock_service"
  spec.add_dependency "pact-provider-verifier"
  spec.add_dependency "pact_broker-client", "~> 1.28"
  spec.add_dependency "json", "~>2.18" # must match native lib install in the Dockerfile
  spec.add_dependency "bigdecimal", "~>3.2" # must match native lib install in the Dockerfile
  spec.add_dependency "io-console", "~>0.8" # must match native lib install in the Dockerfile

  spec.add_dependency "rack-test", ">= 0.6.3", "< 3.0.0"

  spec.add_development_dependency "bump", "~> 0.9"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
