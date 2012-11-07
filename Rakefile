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

# Import nanoc built-in tasks
require 'nanoc/tasks'

# Load custom task helpers
Dir[File.dirname(__FILE__) + '/tasks/**/*.rb'].each do |f|
  load f
end

# Load custom tasks
Dir[File.dirname(__FILE__) + '/tasks/**/*.rake'].each do |f|
  Rake.import f
end

namespace :publish do

  desc "Compile and publish in staging mode"
  task :staging do
    pub = Rfc1459::Newblog::Tasks::Publish.new('staging')
    pub.run
  end

end

desc "Compile and publish in production mode"
task :publish do
  pub = Rfc1459::Newblog::Tasks::Publish.new('production')
  pub.run
end
