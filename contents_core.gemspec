$:.push File.expand_path('../lib', __FILE__)

require 'contents_core/version'

Gem::Specification.new do |s|
  s.name        = 'contents_core'
  s.version     = ContentsCore::VERSION
  s.authors     = ['Mat']
  s.email       = ['mat@blocknot.es']
  s.homepage    = 'https://github.com/blocknotes/contents_core'
  s.summary     = 'Flexible contents structure for Rails (MongoDB version)'
  s.description = 'A Rails gem which offer a structure to manage contents in a flexible way: blocks with recursive nested blocks + items as "leaves"'
  s.license     = 'MIT'

  s.files = Dir["{app,config,db,lib}/**/*", 'MIT-LICENSE', 'Rakefile', 'README.md']

  s.add_dependency 'rails', '~> 5.1'
  s.add_dependency 'mongoid', '~> 6'

  s.add_development_dependency 'sqlite3', '~> 1.3'
  s.add_development_dependency 'pry', '~> 0.11'
  s.add_development_dependency 'simplecov', '~> 0.15'
end
