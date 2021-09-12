#!/usr/bin/env ruby #rubocop:disable Style / FileName

appoint_directory = ARGV[0]
directorys = Dir.glob('*', base: appoint_directory)
max_size_directory = directorys.max_by(&:length)
max_size_directory ||= 0
max_size = max_size_directory.size + 2

empty_space_added_directorys = []
directorys.each do |empty_space|
  empty_space_added_directorys << empty_space.ljust(max_size)
end

number_of_columns = 3
loop do
  break if (empty_space_added_directorys.size % number_of_columns).zero?

  empty_space_added_directorys << nil
end

if empty_space_added_directorys[0].nil?
  loop do
    break if empty_space_added_directorys.size == number_of_columns

    empty_space_added_directorys << nil
  end
end
column_element = empty_space_added_directorys.size / number_of_columns

folders = []
empty_space_added_directorys.each_slice(column_element) do |folder|
  folders << folder
end

folders.transpose.each do |file|
  print "#{file.join}\n"
end
