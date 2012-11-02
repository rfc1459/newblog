# lib/environments.rb - Support for multiple deployment environments
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

module Rfc1459

  module Environments

    require 'yaml'

    def load_local_configuration(environ=nil)
      env_filename = 'environments/' + (environ.nil? ? 'development' : environ) + '.yaml'
      if File.exists?(env_filename)
        @config.merge!(YAML.load_file(env_filename).symbolize_keys)
      end
    end

  end

end

include Rfc1459::Environments
