#!/usr/bin/env ruby #rubocop:disable Style / FileName

specified_directory = ARGV[0]
directories = Dir.glob('*', base: specified_directory)
max_size_directory = directories.max_by(&:length)
return if directories == []

max_size = max_size_directory.size + 2
empty_space_added_directories = []
directories.each do |empty_space|
  empty_space_added_directories << empty_space.ljust(max_size)
end

number_of_columns = 3.0
number_of_lines = (empty_space_added_directories.size / number_of_columns).ceil

if empty_space_added_directories.size < number_of_columns
  (number_of_columns - empty_space_added_directories.size).to_i.times { empty_space_added_directories << nil }
end

nil_add = ((number_of_columns * number_of_lines) - empty_space_added_directories.size).to_i
nil_add.times { empty_space_added_directories << nil }

directory_lines = []
empty_space_added_directories.each_slice(number_of_lines) do |directory_columns|
  directory_lines << directory_columns
end

directory_lines.transpose.each do |file|
  puts file.join
end
