#!/usr/bin/env ruby
i = 0
while i <= 19
  i = i + 1
  print i,"\n" unless i % 5 ==0 && i % 3 ==0 || i % 3 == 0 || i % 5 == 0
  if i % 5 ==0 && i % 3 ==0
    print "FizzBuzz\n"
  elsif i % 3 == 0
    print "Fizz\n"
  elsif i % 5 == 0
    print "Buzz\n"
  end
end
