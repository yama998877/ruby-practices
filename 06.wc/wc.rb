#!/usr/bin/env ruby
# frozen_string_literal: true

class Option
  require 'optparse'
  def initialize(argv)
    @argv = argv
    @options = {}
    OptionParser.new do |o|
      o.on('-l') { |v| @options[:l] = v }
      o.parse!(@argv)
    end
  end

  def has?(name)
    @options.include?(name)
  end

  def specified_file
    @argv
  end
end

def main
  option = Option.new(ARGV)
  if File.pipe?($stdin)
    pipe_wc(option)
  else
    file_wc(option)
  end
end

def pipe_wc(option)
  str = $stdin.read
  puts count_list(str, option, nil)
end

def file_wc(option)
  total_line_count = 0
  total_word_count = 0
  total_bytes_count = 0
  option.specified_file.each do |file|
    puts "wc: #{file}: read: Is a directory" if File.directory?(file)
    next if File.directory?(file)

    puts "wc: #{file}: open: No such file or directory" unless File.exist?(file)
    next unless File.exist?(file)

    str = File.read(file)
    total_line_count += line_count(str).to_i
    total_word_count += word_count(str, option).to_i
    total_bytes_count += bytes_count(str, option).to_i
    puts count_list(str, option, file)
  end
  total_count_list(option, total_line_count, total_word_count, total_bytes_count)
end

def count_list(str, option, file)
  [
    line_count(str),
    word_count(str, option),
    bytes_count(str, option),
    file.nil? ? nil : space_added_filename(file)
  ].join
end

def line_count(str)
  str.count("\n").to_s.rjust(8)
end

def word_count(str, option)
  ary = str.scan(/\s+/)
  ary.size.to_s.rjust(8) unless option.has?(:l)
end

def bytes_count(str, option)
  str.bytesize.to_s.rjust(8) unless option.has?(:l)
end

def space_added_filename(file)
  space = file.size + 1
  file.rjust(space)
end

def total_count_list(option, total_line_count, total_word_count, total_bytes_count)
  return if option.specified_file.size <= 1

  print total_line_count.to_s.rjust(8).to_s
  unless option.has?(:l)
    print total_word_count.to_s.rjust(8).to_s
    print total_bytes_count.to_s.rjust(8)
  end
  puts ' total'
end

main
