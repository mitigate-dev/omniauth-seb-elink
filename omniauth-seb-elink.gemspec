# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'omniauth/seb/version'

Gem::Specification.new do |gem|
  gem.name          = 'omniauth-seb-elink'
  gem.version       = Omniauth::Seb::VERSION
  gem.authors       = ['MAK IT']
  gem.email         = ['admin@makit.lv']
  gem.description   = %q{OmniAuth strategy for SEB e-link}
  gem.summary       = %q{OmniAuth strategy for SEB e-link}
  gem.homepage      = 'https://github.com/mak-it/omniauth-seb-elink'
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.required_ruby_version = '>= 2.2.2'

  gem.add_runtime_dependency 'omniauth', '~> 1.0'
  gem.add_runtime_dependency 'i18n'

  gem.add_development_dependency 'rack-test'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rake'
end
