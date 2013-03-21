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
    gem 'therubyracer', "~> 0.10.0"
    gem 'ruby-prof'
  end

  platforms :mri_19 do
    gem 'debugger'
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

