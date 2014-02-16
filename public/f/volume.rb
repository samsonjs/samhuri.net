#!/usr/bin/env ruby

Ops = {
  :+ => [lambda { |x| x + 5 > 100 ? 100 : x + 5 }, "increased"],
  :- => [lambda { |x| x - 5 < 0   ?   0 : x - 5 } , "decreased"]
}

def vol_op id, vol
  [Ops[id].first.call(vol), Ops[id].last]
end

op = ARGV.shift.to_sym
unless Ops.keys.include?(op)
  raise "#{op} is not a valid argument. Expected one of: #{Ops.keys.join(', ')}."
else
  `amixer get Master`.split("\n").grep(/%/).first =~ /\[(\d+)/
  vol = $1.to_i
  new_vol, action = *vol_op(op, vol)
  system("amixer set Master #{new_vol}%")
  system("notify-send --urgency=low --icon=~/.icons/audio-volume-medium.gif --expire-time=500 \"Volume #{action}\" \"#{new_vol}%\"")
end
