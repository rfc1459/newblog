# lib/tasks/assets.rb - assets management tasks
# Copyright (c) 2012-2014, Matteo Panella <morpheus@level28.org>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#  1. Redistributions of source code must retain the above copyright notice,
#     this list of conditions and the following disclaimer.
#
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

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
