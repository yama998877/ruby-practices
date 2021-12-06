#!/usr/bin/env ruby
# frozen_string_literal: true

WHITE_SPACE = 2
NUMBER_OF_COLUMNS = 3
require 'etc'
class Option
  require 'optparse'
  def initialize(argv)
    @argv = argv
    @options = {}
    OptionParser.new do |o|
      o.on('-a') { |v| @options[:a] = v }
      o.on('-r') { |v| @options[:r] = v }
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

  def file_specified?
    FileTest.file?(specified_directory_file) unless specified_directory_file.nil?
  end

  def specified_directory_file
    @argv[0]
  end
end

def file_type_char(name)
  {
    'fifo' => 'p',
    'characterSpecial' => 'c',
    'directory' => 'd',
    'blockSpecial' => 'b',
    'file' => '-',
    'link' => 'l',
    'socket' => 's'
  }[name]
end

def permission_char(octal_number)
  {
    '0' => '---',
    '1' => '--x',
    '2' => '-w-',
    '3' => '-wx',
    '4' => 'r--',
    '5' => 'r-x',
    '6' => 'rw-',
    '7' => 'rwx'
  }[octal_number]
end

def selected_path(option, dir_file)
  if option.specified_directory_file.nil?
    File::Stat.new(dir_file)
  elsif option.file_specified?
    File::Stat.new(dir_file)
  else
    File::Stat.new(option.specified_directory_file + dir_file)
  end
end

def fs_list(file_status, file_mode, user_name, group_name, dir_file)
  file_type_char(file_status.ftype) +
    permission_char(file_mode[3]) +
    permission_char(file_mode[4]) +
    permission_char(file_mode[5]) +
    " #{file_status.nlink.to_s.rjust(3)}"\
    " #{user_name}  #{group_name}"\
    " #{file_status.size.to_s.rjust(6)}"\
    " #{file_status.mtime.mon.to_s.rjust(2)}"\
    " #{file_status.mtime.strftime('%e %R')} #{dir_file}"
end

def ls_main(directories)
  max_size_directory = directories.max_by(&:length)
  max_size = max_size_directory.size + WHITE_SPACE

  white_space_added_directories = directories.map { |white_space_added_directory| white_space_added_directory.ljust(max_size) }

  number_of_lines = (white_space_added_directories.size.to_f / NUMBER_OF_COLUMNS).ceil

  nil_padding = ((NUMBER_OF_COLUMNS * number_of_lines) - white_space_added_directories.size).to_i
  nil_padding.times { white_space_added_directories << nil }

  directory_lines = []
  white_space_added_directories.each_slice(number_of_lines) do |directory_columns|
    directory_lines << directory_columns
  end

  directory_lines.transpose.each do |file|
    puts file.join
  end
end

option = Option.new(ARGV)
directories =
  if option.file_specified?
    Dir.glob(option.specified_file)
  elsif option.has?(:a)
    Dir.glob('*', File::FNM_DOTMATCH, base: option.specified_directory_file)
  else
    Dir.glob('*', base: option.specified_directory_file)
  end

directories = directories.reverse if option.has?(:r)

if option.specified_directory_file.to_s.empty? != true && FileTest.exist?(option.specified_directory_file.to_s) != true
  puts "ls: #{option.specified_directory_file}: No such file or directory"
end

return if directories == []

if option.has?(:l)
  block_size = 0
  long_lists = []
  directories.each do |dir_file|
    file_status = selected_path(option, dir_file)
    block_size += file_status.blocks
    user_id    = file_status.uid
    user_name  = Etc.getpwuid(user_id).name
    group_id   = file_status.gid
    group_name = Etc.getgrgid(group_id).name
    file_mode = format('%06d', file_status.mode.to_s(8))
    long_lists << fs_list(file_status, file_mode, user_name, group_name, dir_file)
  end
  puts "total #{block_size}" unless option.file_specified?
  puts long_lists
else
  ls_main(directories)
end
