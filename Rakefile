# Rakefile - master Rakefile for newblog
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

# Add "lib" to the current load path
$:.unshift File.expand_path("../lib", __FILE__)

# Import nanoc built-in tasks
require 'nanoc/tasks'

# Load tasks
require 'newblog/tasks'

include Rfc1459::Newblog::Tasks

namespace :publish do

  desc "Compile and publish in staging mode"
  Rfc1459::Newblog::Tasks::Publish.new :staging do |t|
    t.mode = :staging
  end

end

desc "Compile and publish in production mode"
Rfc1459::Newblog::Tasks::Publish.new do |t|
  t.mode = :production
end
