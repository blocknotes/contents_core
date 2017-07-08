$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "contents_core/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "contents_core"
  s.version     = ContentsCore::VERSION
  s.authors     = ["Mat"]
  s.email       = ["mat@blocknot.es"]
  s.homepage    = "https://blocknot.es"
  s.summary     = "CMS core structure"
  s.description = "CMS core structure"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  # s.add_dependency "rails", "~> 5.1.2"

  # s.add_development_dependency "sqlite3"
end
