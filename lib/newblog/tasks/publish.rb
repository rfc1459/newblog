# lib/tasks/publish.rb - publish helper
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
require 'rake/tasklib'
require 'nanoc'
require 'nanoc/cli'

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
