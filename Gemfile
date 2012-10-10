source "http://rubygems.org"

# Declare your gem's dependencies in umlaut.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# jquery is used by the dummy application
group :development, :test do
  platforms :jruby do
    gem 'activerecord-jdbc-adapter', :require => false
    gem 'jdbc-mysql', :require => false
    gem 'jruby-rack'
    gem 'therubyrhino'
    gem 'jruby-prof'
    gem 'jruby-openssl'
  end

  platforms :ruby do
    gem 'mysql2'
    gem 'therubyracer'
    gem 'ruby-prof'
  end

  gem 'jquery-rails'
  gem "activerecord-import"
end

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use debugger
# gem 'ruby-debug'
