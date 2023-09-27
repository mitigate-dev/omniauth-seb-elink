# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'omniauth/seb/version'

Gem::Specification.new do |gem|
  gem.name          = 'omniauth-seb-elink'
  gem.version       = Omniauth::Seb::VERSION
  gem.authors       = ['Mitigate']
  gem.email         = ['admin@mitigate.dev']
  gem.description   = %q{OmniAuth strategy for SEB e-link}
  gem.summary       = %q{OmniAuth strategy for SEB e-link}
  gem.homepage      = 'https://github.com/mitigate-dev/omniauth-seb-elink'
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.required_ruby_version = '>= 2.7'

  gem.add_runtime_dependency 'omniauth', '~> 2.1'
  gem.add_runtime_dependency 'i18n'

  gem.add_development_dependency 'rack-test'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rack-session'
end
