# lib/tasks/assets.rb - assets management tasks
# Copyright (C) 2012 Matteo Panella <morpheus@level28.org>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'rake'
require 'rake/clean'
require 'rake/tasklib'
require 'nanoc'

module Rfc1459::Newblog::Tasks

  class BuildAssets < Rake::TaskLib

    DEFAULT_SOURCE_DIR = File.join('assets', 'src') unless defined? DEFAULT_SOURCE_DIR
    DEFAULT_TARGET_DIR = File.join('content', 'assets') unless defined? DEFAULT_TARGET_DIR

    def initialize(name = :assets)
      @name = name
      @source_dir = DEFAULT_SOURCE_DIR
      @target_dir = DEFAULT_TARGET_DIR
      yield(self) if block_given?
      self.define
    end

    attr_reader :name

    attr_accessor :source_dir, :target_dir

    def define
      CLOBBER.include(@target_dir)

      # Set a default description if the caller didn't give one
      unless Rake.application.last_comment
        desc "Generate blog assets."
      end

      task @name => [ "#{@name}:build" ]

      namespace(self.name) do

        # Build minified CSS overrides: this is a stop-gap solution until
        # I find a better way of handling them (perhaps version-controlling
        # the minified css itself and getting rid of the assets task?)
        # 2014/10/26 -morph
        css = File.join(@target_dir, 'css')
        directory css
        file css => @target_dir

        # Minify CSS files
        rule '.min.css' => [
          proc { |target| File.join @source_dir, File.basename(target).gsub(/\.min\.css$/, '.css') }
        ] do |t|
          sh %{recess --compress #{t.source} > #{t.name}}
        end

        overrides_min_css = File.join(css, 'overrides.min.css')
        file overrides_min_css => [ css, File.join(@source_dir, 'overrides.css') ]

        task :build => overrides_min_css

      end
    end

  end

end
