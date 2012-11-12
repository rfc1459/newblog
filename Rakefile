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

# Load tasks
require 'rake/clean'
require 'newblog/tasks'

include Rfc1459::Newblog::Tasks

# Create assets management tasks
BuildAssets.new

CLEAN.include("output")
CLOBBER.include("tmp")

namespace :publish do

  desc "Compile and publish in staging mode"
  Publish.new :staging => [ "rake:assets" ] do |t|
    t.mode = :staging
  end

end

desc "Compile and publish in production mode"
Publish.new :publish => :assets do |t|
  t.mode = :production
end

# Emergency reset switch (just in case)
namespace :emergency do
  task :reset do
    # This can fail
    begin
      Rake::Task["assets:unapply_quilt"].execute
    rescue
    end
    Rake::Task["clobber"].execute
  end
end
