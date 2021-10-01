#!/usr/bin/env ruby #rubocop:disable Style / FileName

class Option
  require 'optparse'
  def initialize
    @options = {}
    OptionParser.new do |o|
      o.on('-a') { |v| @options[:a] = v }
      o.parse!(ARGV)
    end
  end

  def has?(name)
    @options.include?(name)
  end

  def pull_extra
    ARGV[0]
  end
end

option = Option.new
specified_directory = option.pull_extra
directories =
  if option.has?(:a)
    Dir.glob('*', File::FNM_DOTMATCH, base: specified_directory)
  else
    Dir.glob('*', base: specified_directory)
  end
max_size_directory = directories.max_by(&:length)
return if directories == []

max_size = max_size_directory.size + 2
empty_space_added_directories = []
directories.each do |empty_space|
  empty_space_added_directories << empty_space.ljust(max_size)
end

number_of_columns = 3.0
number_of_lines = (empty_space_added_directories.size / number_of_columns).ceil

nil_padding = ((number_of_columns * number_of_lines) - empty_space_added_directories.size).to_i
nil_padding.times { empty_space_added_directories << nil }

directory_lines = []
empty_space_added_directories.each_slice(number_of_lines) do |directory_columns|
  directory_lines << directory_columns
end

directory_lines.transpose.each do |file|
  puts file.join
end
