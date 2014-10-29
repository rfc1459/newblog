# lib/helpers.rb - General-purpose helpers
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

# Silly, but required by Nanoc
$:.unshift File.expand_path("..", __FILE__)

require 'newblog'
require 'nokogiri'
require 'redcarpet'

include Nanoc::Helpers::Rendering
include Nanoc::Helpers::Blogging
include Nanoc::Helpers::Tagging
include Nanoc::Helpers::XMLSitemap
include Rfc1459::Newblog::Environments
include Rfc1459::Newblog::Navigation
include Rfc1459::Newblog::Archives
include Rfc1459::Newblog::Tagging

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

module Rfc1459::Newblog::Cached
  extend Nanoc::Memoization

  def front_page_articles
    sorted_articles.slice(0, @config[:posts_per_page])
  end
  memoize :front_page_articles

  def all_tags
    tags = []
    articles.each do |post|
      unless post[:tags].nil?
        tags.concat(post[:tags])
      end
    end
    tags.sort!.uniq
  end
  memoize :all_tags

end
include Rfc1459::Newblog::Cached

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
  item[:content_filename].gsub(/^content\/assets/, '').gsub(/_/, '.')
end

def route_generic(item)
  item[:content_filename].gsub(/^content/, '')
end

class PygmentsRenderer < Redcarpet::Render::HTML
  def block_code(code, language)
    if language.nil?
      "<pre><code>#{code.gsub(/[<>]/, '<' => '&lt;', '>' => '&gt;')}</code></pre>\n"
    else
      "<div class=\"highlight\"><pre><code class=\"language-#{language}\">\n#{code.gsub(/[<>]/, '<' => '&lt;', '>' => '&gt;')}\n</code></pre></div>\n"
    end
  end
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
  more = root.xpath('descendant::comment()[.=" break "]')
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
