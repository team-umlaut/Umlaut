source "http://rubygems.org"

# Declare your gem's dependencies in umlaut.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# jquery is used by the dummy application
group :development, :test do
  platforms :jruby do
    gem 'activerecord-jdbc-adapter', "~> 1.2.9"
    gem 'jdbc-mysql', "~> 5.1.24", :require => false
    gem 'jruby-rack'
    gem 'therubyrhino'
    gem 'jruby-openssl'
  end

  platforms :ruby do
    gem 'mysql2', "~> 0.3.11"
    gem 'therubyracer', "~> 0.11.4"
  end

  platforms :mri do
    gem 'ruby-prof', "~> 0.13.0"
    gem 'debugger', "~> 1.5.0"
  end

  gem 'jquery-rails'
  gem "activerecord-import"
end

# Add coveralls for testing.
gem "coveralls", "~> 0.6.0", :require => false, :group => :test

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

