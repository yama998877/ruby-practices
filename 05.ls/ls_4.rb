#!/usr/bin/env ruby #rubocop:disable Style / FileName
require 'etc'

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

  def specified_directory
    @argv[0]
  end
end

def convert_file_type_into_character(name)
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

def convert_octal_number_into_character(number)
  {
    '0' => '---',
    '1' => '--x',
    '2' => '-w-',
    '3' => '-wx',
    '4' => 'r--',
    '5' => 'r-x',
    '6' => 'rw-',
    '7' => 'rwx'
  }[number]
end

option = Option.new(ARGV)
directories = Dir.glob('*', base: option.specified_directory)

return if directories == []

if option.has?(:l)
  block_size = 0
  file_info = []
  directories.each do |dir|
    fs =
      if option.specified_directory.nil?
        File::Stat.new(dir)
      else
        File::Stat.new(option.specified_directory + dir)
      end
    block_size += fs.blocks
    user_id    = fs.uid
    user_name  = Etc.getpwuid(user_id).name
    group_id   = fs.gid
    group_name = Etc.getgrgid(group_id).name
    file_mode = format('%06d', fs.mode.to_s(8))
    file_info <<
      convert_file_type_into_character(fs.ftype) +
      convert_octal_number_into_character(file_mode[3]) +
      convert_octal_number_into_character(file_mode[4]) +
      convert_octal_number_into_character(file_mode[5]) +
      " #{fs.nlink.to_s.rjust(3)} #{user_name}  #{group_name} #{fs.size.to_s.rjust(6)} #{fs.mtime.mon.to_s.rjust(2)} #{fs.mtime.strftime('%e %R')} #{dir}"
  end
  puts "total #{block_size}"
  puts file_info
else
  WHITE_SPACE = 2
  max_size_directory = directories.max_by(&:length)
  max_size = max_size_directory.size + WHITE_SPACE
  empty_space_added_directories = []
  directories.each do |empty_space|
    empty_space_added_directories << empty_space.ljust(max_size)
  end

  NUMBER_OF_COLUMNS = 3
  number_of_lines = (empty_space_added_directories.size.to_f / NUMBER_OF_COLUMNS).ceil

  nil_padding = ((NUMBER_OF_COLUMNS * number_of_lines) - empty_space_added_directories.size).to_i
  nil_padding.times { empty_space_added_directories << nil }

  directory_lines = []
  empty_space_added_directories.each_slice(number_of_lines) do |directory_columns|
    directory_lines << directory_columns
  end

  directory_lines.transpose.each do |file|
    puts file.join
  end
end
