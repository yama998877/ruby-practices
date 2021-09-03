#!/usr/bin/env ruby#rubocop:disable Style / FileName
score = ARGV[0]
scores = score.split(',')

shots = []
scores.each do |shot|
  if shot == 'X' && shots.size < 18
    shots << 10
    shots << 0
  elsif shot == 'X'
    shots << 10
  else
    shots << shot.to_i
  end
end

frames = []
shots.each_slice(2) do |frame|
  frames << frame if frames.size < 9
end
frames << shots.slice(18, 20)

points = []
frames.each_with_index do |point, index|
  points <<
    if point[0] == 10 && points.size < 8 && frames[index + 1][0] == 10
      point.sum + frames[index + 1][0..1].sum + frames[index + 2][0]
    elsif point[0] == 10 && points.size < 9
      point.sum + frames[index + 1][0..1].sum
    elsif point[0] + point[1] == 10 && points.size < 9
      point.sum + frames[index + 1][0]
    else
      point.sum
    end
end

p points.sum
