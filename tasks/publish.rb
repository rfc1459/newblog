# tasks/publish.rb - Helper class for environment-based publishing
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

require 'nanoc'

module Rfc1459

  module Newblog

    module Tasks
      class Publish

        def initialize(environ)
          @environ = environ
          @old_env = nil
        end

        def run
          dry_run = !!ENV['dry_run']
          set_environment

          unless dry_run
            Nanoc::CLI.run %w( compile )
          end

          cmd = [ 'deploy', '-t', @environ ]
          cmd << '-n' if dry_run

          Nanoc::CLI.run cmd

          reset_environment
        end

      private

        def set_environment
          @old_env = ENV['environment']
          ENV['environment'] = @environ
        end

        def reset_environment
          ENV['environment'] = @old_env
        end

      end

    end

  end

end
