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

    DEFAULT_WORK_AREA = 'work' unless defined? DEFAULT_WORK_AREA
    DEFAULT_SOURCE_DIR = File.join('assets', 'src') unless defined? DEFAULT_SOURCE_DIR
    DEFAULT_TARGET_DIR = File.join('content', 'assets') unless defined? DEFAULT_TARGET_DIR

    def initialize(name = :assets)
      @name = name
      @work_area = DEFAULT_WORK_AREA
      @source_dir = DEFAULT_SOURCE_DIR
      @target_dir = DEFAULT_TARGET_DIR
      yield(self) if block_given?
      self.define
    end

    attr_reader :name

    attr_accessor :work_area, :source_dir, :target_dir

    def define
      # Set a default description if the caller didn't give one
      unless Rake.application.last_comment
        desc "Generate blog assets"
      end

      CLEAN.include(@work_area)
      CLOBBER.include(@target_dir)

      task @name => [ @target_dir ]

      namespace(self.name) do

        # Initialize required Git submodules
        task :submodules do
          sh %{git submodule init}
          sh %{git submodule update}
        end

        # Apply quilt patches
        task :apply_quilt => [ :submodules ] do
          sh %{quilt push -a}
        end

        # Clear quilt patches
        task :unapply_quilt do
          sh %{quilt pop -a}
        end

        # Work area
        directory @work_area
        file @work_area => [ :apply_quilt ] do
          cp_r Dir["#{@source_dir}/bootstrap/*"], @work_area
          rm_rf File.join(@work_area, "img")
        end

        # Font directory
        font_dir = File.join(@work_area, "font")
        directory font_dir
        file font_dir => [ @work_area ] do
          Dir["#{@source_dir}/fontawesome/font/*"].each do |f|
            cp f, "#{font_dir}/#{File.basename f.gsub(/\./, '_')}"
          end
        end

        # Less files
        font_awesome_less = "#{@work_area}/less/font-awesome.less"
        file font_awesome_less => [ @work_area ] do
          cp Dir["#{@source_dir}/fontawesome/less/font-awesome.less"], "#{@work_area}/less"
        end

        task :prepare => [:apply_quilt, @work_area, font_dir, font_awesome_less, :unapply_quilt]

        # Build assets
        directory @target_dir
        file @target_dir => [ :prepare ] do
          sh %{make -C #{@work_area} bootstrap}
          Dir["#{@work_area}/bootstrap/css/*.css"].each do |f|
            # Remove non-minified CSSes
            rm f if /^(bootstrap\.css|bootstrap-responsive.css)$/ =~ File.basename(f)
          end
          # Remove non-minified js
          rm "#{@work_area}/bootstrap/js/bootstrap.js"
          mkdir_p @target_dir
          cp_r "#{@work_area}/bootstrap", "#{@target_dir}/bootstrap"
          rm_rf @work_area
          cp "#{@source_dir}/overrides.css", "#{@target_dir}/bootstrap/css"
        end

      end
    end

  end

end
