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

def select_path(option, dir_file)
  if option.specified_directory_file.nil? || option.file_specified?
    dir_file
  else
    option.specified_directory_file + dir_file
  end
end

def fs_list(file_stats, file_mode, user_name, group_name, dir_file)
  [
    file_type_char(file_stats.ftype),
    permission_char(file_mode[3]),
    permission_char(file_mode[4]),
    permission_char(file_mode[5]),
    file_stats.nlink.to_s.rjust(3),
    user_name.rjust(11),
    group_name.rjust(6),
    file_stats.size.to_s.rjust(5),
    file_stats.mtime.mon.to_s.rjust(3),
    file_stats.mtime.strftime(' %e %R '),
    dir_file
  ].join
end

def main(directories_files, option)
  if option.has?(:l)
    l_option_ls(directories_files, option)
  else
    column_ls(directories_files)
  end
end

def l_option_ls(directories_files, option)
  block_size = 0
  long_lists = []
  directories_files.each do |dir_file|
    file_stats = File::Stat.new(select_path(option, dir_file))
    block_size += file_stats.blocks
    user_id = file_stats.uid
    user_name = Etc.getpwuid(user_id).name
    group_id = file_stats.gid
    group_name = Etc.getgrgid(group_id).name
    file_mode = format('%06d', file_stats.mode.to_s(8))
    long_lists << fs_list(file_stats, file_mode, user_name, group_name, dir_file)
  end
  puts "total #{block_size}" unless option.file_specified?
  puts long_lists
end

def column_ls(directories_files)
  max_size_directory = directories_files.max_by(&:length)
  max_size = max_size_directory.size + WHITE_SPACE

  white_space_added_directories_files = directories_files.map { |white_space_added_directory| white_space_added_directory.ljust(max_size) }

  number_of_lines = (white_space_added_directories_files.size.to_f / NUMBER_OF_COLUMNS).ceil

  nil_padding = ((NUMBER_OF_COLUMNS * number_of_lines) - white_space_added_directories_files.size).to_i
  nil_padding.times { white_space_added_directories_files << nil }

  directory_lines = []
  white_space_added_directories_files.each_slice(number_of_lines) do |directory_columns|
    directory_lines << directory_columns
  end

  directory_lines.transpose.each do |file|
    puts file.join
  end
end

option = Option.new(ARGV)
directories_files =
  if option.file_specified?
    Dir.glob(option.specified_file)
  else
    flags = option.has?(:a) ? File::FNM_DOTMATCH : 0
    Dir.glob('*', flags, base: option.specified_directory_file)
  end

directories_files = directories_files.reverse if option.has?(:r)

directory_file_path

if !option.specified_directory_file.to_s.empty? && !FileTest.exist?(option.specified_directory_file.to_s)
  puts "ls: #{option.specified_directory_file}: No such file or directory"
end

return if directories_files == []

main(directories_files, option)
