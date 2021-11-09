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

def convert_into_permission(name)
  {
    'fifo' => 'p',
    'characterSpecial' => 'c',
    'directory' => 'd',
    'blockSpecial' => 'b',
    'file' => '-',
    'link' => 'l',
    'socket' => 's',
    '0' => '---',
    '1' => '--x',
    '2' => '-w-',
    '3' => '-wx',
    '4' => 'r--',
    '5' => 'r-x',
    '6' => 'rw-',
    '7' => 'rwx'
  }[name]
end

option = Option.new(ARGV)
directories = Dir.glob('*', base: option.specified_directory)

return if directories == []

if option.has?(:l)
  file_size = 0
  directories.each do |size|
    fs =
      if option.specified_directory.nil?
        File::Stat.new(size)
      else
        File::Stat.new(option.specified_directory + size)
      end
    file_size += fs.blocks
  end
  puts "total #{file_size}"

  directories.each do |dir|
    fs =
      if option.specified_directory.nil?
        File::Stat.new(dir)
      else
        File::Stat.new(option.specified_directory + dir)
      end
    user_id    = fs.uid
    user_name  = Etc.getpwuid(user_id).name
    group_id   = fs.gid
    group_name = Etc.getgrgid(group_id).name
    file_mode = format('%06d', fs.mode.to_s(8))
    print convert_into_permission(fs.ftype)
    print convert_into_permission(file_mode[3])
    print convert_into_permission(file_mode[4])
    print convert_into_permission(file_mode[5])
    print " #{fs.nlink.to_s.rjust(3)} #{user_name}  #{group_name} #{fs.size.to_s.rjust(6)} #{fs.mtime.mon.to_s.rjust(2)} #{fs.mtime.strftime('%e %R')} "
    print "#{dir}\n"
  end
end

return if option.has?(:l)

max_size_directory = directories.max_by(&:length)
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
