# lib/helpers.rb - General-purpose helpers
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

include Nanoc::Helpers::Rendering

def get_title
  subtitle = is_front_page? ? "Home" : @item[:title]
  @config[:blog_name] + " :: " + subtitle
end

def is_front_page?
  @item.identifier == '/'
end

def is_current_item?(nav_entry)
  not @item[:nav_id].nil? and nav_entry.has_key?(:nav_id) and @item[:nav_id] == nav_entry[:nav_id]
end

def route_path(item)
  # in-memory items do not have a file name
  return item.identifier + "index.html" if item[:content_filename].nil?

  url = item[:content_filename].gsub(/^content/, '')

  extname = '.' + item[:extension].split('.').last
  outext = '.haml'
  if url.match(/(\.[a-zA-Z0-9]+){2}$/)
    outext = ''
  elsif extname == ".less"
    outext = '.css'
  elsif url.match(/^\/js/)
    outext = '.js'
  else
    outext = '.html'
  end
  url.gsub!(extname, outext)

  if url.include?('-')
    url = url.split('-').join('/')
  end

  url
end

def route_assets(item)
  item[:content_filename].gsub(/^content\/assets\/[^\/]+/, '').gsub(/_/, '.')
end
