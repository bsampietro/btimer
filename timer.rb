#!/usr/bin/ruby

require 'yaml'

FILE_PATH = "#{File.expand_path(File.dirname(__FILE__))}/data.yml"
TIME_NOW = Time.now

def save
  File.open(FILE_PATH, 'w') do |out|
    YAML.dump(@data, out)
  end
end

#def duration
#  secs  = self.to_int
#  mins  = secs / 60
#  hours = mins / 60
#  days  = hours / 24

#  if days > 0
#    "#{days} days and #{hours % 24} hours"
#  elsif hours > 0
#    "#{hours} hours and #{mins % 60} minutes"
#  elsif mins > 0
#    "#{mins} minutes and #{secs % 60} seconds"
#  elsif secs >= 0
#    "#{secs} seconds"
#  end
#end

def duration(elapsed_time)
  secs  = elapsed_time.to_i
  mins  = secs / 60
  hours = mins / 60
  fsecs = (secs % 60).to_s.rjust(2, '0')
  fmins = (mins % 60).to_s.rjust(2, '0')
  fhours = hours.to_s.rjust(2, '0')

  if hours > 0
    "#{fhours}:#{fmins}:#{fsecs}"
  elsif mins > 0
    "00:#{fmins}:#{fsecs}"
  elsif secs >= 0
    "00:00:#{fsecs}"
  end
end

def get_seconds(str)
  time = str.split(':')
  time[0].to_i * 3600 + time[1].to_i * 60 + time[2].to_i
end

def display_elapsed
  seconds_passed = @data[:state] == :started ? (TIME_NOW - @data[:start]) + @data[:elapsed] : @data[:elapsed]
  puts duration(seconds_passed)
end

@data = YAML.load_file(FILE_PATH) rescue {:start => TIME_NOW, :elapsed => 0, :state => :stopped}

if ARGV.first == "start"
  if @data[:state] == :stopped
    @data[:start] = TIME_NOW
    @data[:state] = :started
    save
  end
elsif ARGV.first == "stop"
  if @data[:state] == :started
    @data[:state] = :stopped
    @data[:elapsed] += TIME_NOW - @data[:start]
    save
  end
elsif ARGV.first == "reset"
  @data[:elapsed] = 0
  @data[:start] = TIME_NOW
  save
elsif ARGV.first == "set"
  @data[:elapsed] = get_seconds ARGV[1]
  @data[:start] = TIME_NOW
  save
end

puts @data[:state].to_s
display_elapsed
