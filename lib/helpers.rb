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

# Silly, but required by Nanoc
$:.unshift File.expand_path("..", __FILE__)

require 'newblog'
require 'nokogiri'

include Nanoc::Helpers::Rendering
include Nanoc::Helpers::Blogging
include Rfc1459::Newblog::Environments
include Rfc1459::Newblog::Navigation

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

def front_page_articles
  # FIXME: caching (this function is called twice...)
  sorted_articles.slice(0, @config[:posts_per_page])
end

def mathjax_required?
  if is_front_page?
    front_page_articles.reduce(false) do |required, item|
      required | item[:mathjax_required]
    end
  else
    @item[:mathjax_required]
  end
end

def url_for_article(item)
  url_components = strip_posts_prefix(item.identifier).gsub('-', '/').gsub('_', '-').split('/')
  # ["", "YYYY", "MM", "DD", "slug"] -> ["", "YYYY", "MM", "slug", ""]
  url_components[3] = url_components[4]
  url_components[4] = ""
  return url_components.join('/')
end

def update_articles_timestamps
  items.each do |item|
    # Exclude assets, binary files and xml files from sitemap
    if item[:content_filename]
      begin
        ext = File.extname(route_path(item))
      rescue
        ext = File.extname(route_assets(item))
      end
      item[:is_hidden] = true if item[:content_filename] =~ %r{^content/(assets|js)} || item.binary? || ext == '.xml'
    end

    if item[:kind] == 'article'
      # If the item itself has no date, derive it from its filename
      item[:created_at] ||= created_at(item)
      # Workaround for a nasty nanoc/YAML issue
      item[:created_at] = item[:created_at].to_s if item[:created_at].is_a?(Date)

      # TODO: generate updated_at based on SHA1 sum of content
    end
  end
end

def route_path(item)
  # in-memory items do not have a file name
  return item.identifier + "index.html" if item[:content_filename].nil?

  # Article routes are special ;-)
  return url_for_article(item) + 'index.html' if item[:kind] == 'article'

  url = item[:content_filename].gsub(/^content/, '')

  # Fix output file extension
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

private

def strip_posts_prefix(id)
  id.gsub(/^\/posts/, '')
end

def created_at(item)
  parts = strip_posts_prefix(item.identifier).gsub('-', '/').split('/')[1, 3]
  date = '1970/01/01'
  begin
    tmp = parts.join('/')
    Date.strptime(tmp, "%Y/%m/%d")
    date = tmp
  rescue
  end
  date
end

def article_summary(item)
  root = Nokogiri::HTML::DocumentFragment.parse(item.compiled_content)
  more = root.css('#more')
  # Fast exit
  return item.compiled_content, false if more.empty?
  more.xpath('following-sibling::*').remove
  more.remove
  return root.to_html, true
end

def format_date(date_string)
  begin
    d = Date.parse date_string
    d.strftime('%d/%m/%Y')
  rescue
    date_string
  end
end
