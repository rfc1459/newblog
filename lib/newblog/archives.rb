# lib/newblog/archives.rb - Archives generation
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

require 'nanoc'

module Rfc1459::Newblog

  module Archives

    ITMONTHNAMES = [nil, 'Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno', 'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre'] unless defined? ITMONTHNAMES

    def render_archives
      year = nil
      month = nil
      posts_for_month = []
      posts_for_year_by_month = []
      sorted_articles.each do |item|
        d = Date.parse item[:created_at]
        if d.year != year
          unless month.nil?
            render_month(year, month, posts_for_month)
          end
          unless year.nil?
            render_year(year, posts_for_year_by_month)
          end
          year = d.year
          month = d.month
          posts_for_year_by_month = []
          posts_for_month = []
        elsif d.month != month
          unless month.nil?
            render_month(year, month, posts_for_month)
          end
          posts_for_year_by_month << {:month => month, :posts => posts_for_month}
          month = d.month
          posts_for_month = []
        end

        posts_for_month << item
      end

      unless posts_for_month.empty?
        render_month(year, month, posts_for_month)
        posts_for_year_by_month << {:month => month, :posts => posts_for_month}
      end

      unless posts_for_year_by_month.empty?
        render_year(year, posts_for_year_by_month)
      end
    end

    private

    def render_year(year, months)
      @items << Nanoc::Item.new(
        "<%= render('_archive_year_partial') %>",
        {
          :title => "Archivio per il #{year}",
          :months => months,
          :extension => 'erb'
        },
        "/#{year}",
        :binary => false,
      )
    end

    def render_month(year, month, posts)
      @items << Nanoc::Item.new(
        "<%= render('_archive_month_partial') %>",
        {
          :title => "Archivio per #{ITMONTHNAMES[month]} #{year}",
          :posts => posts,
          :extension => 'erb'
        },
        "/%d/%02d" % [year, month],
        :binary => false,
      )
    end
  end
end
