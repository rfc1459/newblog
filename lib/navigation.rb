# lib/navigation.rb - Generalized navigation data source
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

  module Navigation
    require 'yaml'

    def load_navigation_data(filename='navigation.yaml')
      if File.exists?(filename)
        nav_data = YAML.load_file(filename).symbolize_keys
        # Attach nav_data to global configuration
        @config[:navigation] = nav_data
      else
        raise RuntimeError.new("Navigation data file #{filename} does not exist")
      end
    end

  end

end

include Rfc1459::Navigation
