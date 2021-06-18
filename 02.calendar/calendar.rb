#!/usr/bin/env ruby
#ライブラリの取得
require 'date'
require 'optparse'
#変数、現在の年、月、日
year = Date.today.year
month = Date.today.month
day = Date.today.day
#オプション -y -m
options = ARGV.getopts("", "y:#{Date.today.year}", "m:#{Date.today.month}")
year = options["y"].to_i
month = options["m"].to_i
#月末、月初
last_day = Date.new(year,month,-1)
first_day = Date.new(year,month,+1)
#月 年
month_year = Date.today.strftime("#{month}月 #{year}")
#カレンダー
puts month_year.center(24)
puts " 日 月 火 水 木 金 土"
(first_day..last_day).each do |day|
  if first_day == day && day.saturday?
    print "   " * first_day.wday+" ", "#{day.day}\n".rjust(3)," "
  elsif first_day == day
    print "   " * first_day.wday, "#{day.day}".rjust(3)," "
  elsif day.saturday? && last_day == day
    print "#{day.day}\n".rjust(3)," ","\n"
  elsif day.saturday?
    print "#{day.day}\n".rjust(3)," "
  elsif
    print "#{day.day}".rjust(2)," "
  elsif last_day == day
    print "\n"
  end
end
