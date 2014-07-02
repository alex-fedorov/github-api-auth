source 'https://rubygems.org'

# Specify your gem's dependencies in github-api-auth.gemspec
gemspec

# use all bleeding edge of rspec
%w(core mocks expectations support rails legacy_formatters collection_matchers).each do |part|
  gem "rspec-#{part}", github: "rspec/rspec-#{part}"
end

