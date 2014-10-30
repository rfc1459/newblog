source "https://rubygems.org"

# Selectors for OS-specific gems
def windows_only(require_as)
  RbConfig::CONFIG['host_os'] =~ /mingw|mswin/i ? require_as : false
end

def linux_only(require_as)
  RbConfig::CONFIG['host_os'] =~ /linux/ ? require_as : false
end

def darwin_only(require_as)
  RbConfig::CONFIG['host_os'] =~ /darwin/ ? require_as : false
end

# Pulled straight from nanoc's Gemfile
all_rubies = Bundler::Dependency::PLATFORM_MAP.keys
ruby_19_plus               = [:ruby_19, :ruby_20, :ruby_21, :jruby] & all_rubies
ruby_19_plus_without_jruby = [:ruby_19, :ruby_20, :ruby_21]         & all_rubies

gem 'nanoc'
gem 'guard-nanoc', :platforms => ruby_19_plus
gem 'listen', :platforms => ruby_19_plus
gem 'mime-types', :platforms => ruby_19_plus
gem 'nokogiri', '~> 1.6'
gem 'adsf'
gem 'haml'
gem 'builder'
gem 'activesupport'
gem 'uglifier'
gem 'rake', '~> 0.9.2.2'
gem 'redcarpet', :platforms => ruby_19_plus_without_jruby + [:mswin]
gem 'pygments.rb', :platforms => [:ruby, :mswin]
gem 'thin'

# Listen dependencies
gem 'rb-fsevent', :require => darwin_only('rb-fsevent')
gem 'rb-inotify', :require => linux_only('rb-inotify')
gem 'wdm', :platforms => [:mswin, :mingw], :require => windows_only('wdm')
