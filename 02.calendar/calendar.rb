#!/usr/bin/env ruby
#ライブラリの取得
require 'date'
require 'optparse'
#変数、現在の年、月、日
today_year = Date.today.year
today_month = Date.today.month
#オプション -y -m
options = ARGV.getopts("", "y:#{today_year}", "m:#{today_month}")
today_year = options["y"].to_i
today_month = options["m"].to_i
#月末、月初
last_day = Date.new(today_year,today_month,-1)
first_day = Date.new(today_year,today_month,+1)
#月 年
month_year = Date.today.strftime("#{today_month}月 #{today_year}")
#カレンダー
puts month_year.center(20)
puts "日 月 火 水 木 金 土"
(first_day..last_day).each do |day|
  if first_day == day
    print "   " * first_day.wday
  end
  
  print "#{day.day}".rjust(2)," "

  if day.saturday?
    print "\n"
  end
end
