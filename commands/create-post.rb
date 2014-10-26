# commands/create-post.rb - nanoc CLI extension for new posts
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


usage       'create-post [options] slug'
aliases     :create_post, :cp
summary     'create a new blog post'
description <<-EOS
Create a new blog post in the current site. Without any option, it defaults
to a Markdown-formatted post filed on the current day with the current system
username as author.
EOS

required :f, :format, 'specify post template format (currently supported: md*, haml, erb)' do |value, cmd|
  unless ['erb', 'haml', 'md'].include? value
    raise Nanoc::Errors::GenericTrivial, "Invalid post format specified"
  end
end

required :D, :date, 'specify post date in YYYY/MM/DD format' do |value, cmd|
    # Parse incoming date
    begin
      Date.strptime(value, '%Y/%m/%d')
    rescue
      raise Nanoc::Errors::GenericTrivial, "Invalid date format (expected YYYY/MM/DD)"
    end
end

required :a, :author, "specify the author (default: #{ENV['USER']})"
required :c, :vcs, 'specify the VCS to use'

class CreatePost < ::Nanoc::CLI::CommandRunner

  def run

    # Do we have a slug?
    if arguments.length != 1
      raise Nanoc::Errors::GenericTrivial, "usage: #{command.usage}"
    end
    slug = arguments[0]

    # Validate the slug
    unless /^\w+$/ =~ slug
      raise Nanoc::Errors::GenericTrivial, "Invalid post slug"
    end

    # Ensure we're running inside a nanoc site directory
    self.require_site

    # Set the VCS (if possible)
    self.set_vcs(options[:vcs])

    # Baseline date for post
    timestamp = nil
    if options[:date]
      date = Date.strptime(options[:date], '%Y/%m/%d')
    else
      date = Date.today
      timestamp = DateTime.now
    end

    # Post format (default: markdown)
    fmt = options[:format] || 'md'

    # Author (default: system username)
    author = options[:author] || ENV['USER']

    # Identifier
    identifier = File.join('posts', date.year.to_s, "#{date.strftime('%m-%d')}-#{slug}").cleaned_identifier

    # Check for duplicate articles
    dupe = self.site.items.find { |i| i.identifier == identifier}
    raise Nanoc::Errors::GenericTrivial, "An item already exists at #{url_for_article(dupe)}" unless dupe.nil?

    # Set up notifications
    Nanoc::NotificationCenter.on(:file_created) do |fn|
      Nanoc::CLI::Logger.instance.file(:high, :create, fn)
    end

    # And finally create the post ;-)
    data_source = self.site.data_sources[0]
    data_source.create_item(
      "FIXME: content here, please\n",
      { :title => slug, :kind => "article", :author => author, :created_at => timestamp.to_s },
      identifier,
      { :extension => ".#{fmt}" }
    )
  end

end

runner CreatePost
