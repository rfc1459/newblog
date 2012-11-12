# lib/tasks/publish.rb - publish helper
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
require 'rake/tasklib'
require 'nanoc'

module Rfc1459::Newblog::Tasks

  class Publish < Rake::TaskLib

    ENV_NAME = Rfc1459::Newblog::Environments::ENV_NAME unless defined? ENV_NAME

    attr_accessor :mode

    def initialize(*args, &block)
      task_name, arg_names, @task_dependencies = Rake.application.resolve_args(args)
      @name = task_name ? task_name : :publish
      block.call(self) if block
      define
    end

    def define
      task @name => @task_dependencies do
        unless @mode == :production or @mode == :staging
          raise RuntimeError.new("Unknown publishing mode '#{@mode}'")
        end

        set_environment

        dry_run = !!ENV['dry_run']
        unless dry_run
          Nanoc::CLI.run %w(compile)
        end

        cmd = ['deploy', '-t', @mode.to_s]
        cmd << '-n' if dry_run

        Nanoc::CLI.run cmd

        reset_environment
      end
    end

  private

    def set_environment
      @old_env = ENV[ENV_NAME]
      ENV[ENV_NAME] = @mode.to_s
    end

    def reset_environment
      ENV[ENV_NAME] = @old_env
      @old_env = nil
    end

  end

end
