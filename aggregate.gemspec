$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "aggregate/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "aggregate"
  s.version     = Aggregate::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Aggregate."
  s.description = "TODO: Description of Aggregate."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails",        "~> 3.2.22"
  s.add_dependency "hobo_support", "2.0.1"
  s.add_dependency "large_text_field", "0.0.1"

  s.add_development_dependency "invoca-utils", "0.0.2"
  s.add_development_dependency "sqlite3"
end
