# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "aggregate/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "aggregate"
  s.version     = Aggregate::VERSION
  s.authors     = ["Bob Smith"]
  s.email       = ["bob@invoca.com"]
  s.homepage    = "http://github.com/invoca"
  s.summary     = "A no-sql style document store using mysql"
  s.description = "Store hashes of attributes on active record models.  Add attributes without requiring migrations"
  s.metadata['allowed_push_host'] = "https://gem.fury.io/invoca"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "activerecord",     "~> 4.0"
  s.add_dependency "encryptor",        "~> 3.0"
  s.add_dependency "invoca-utils",     "~> 0.3"
  s.add_dependency "large_text_field", "~> 1.0"
end
