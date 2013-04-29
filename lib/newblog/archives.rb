# lib/newblog/archives.rb - Archives generation
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
