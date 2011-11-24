#!/usr/bin/ruby

require 'yaml'

FILE_PATH = "#{File.expand_path(File.dirname(__FILE__))}/data.yml"
TIME_NOW = Time.now

def save
  File.open(FILE_PATH, 'w') do |out|
    YAML.dump(@data, out)
  end
end

def format(elapsed_seconds)
  secs  = elapsed_seconds.to_i
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

# get number of seconds from a time str like 'xx:xx:xx'
def get_seconds(str)
  time = str.split(':')
  time[0].to_i * 3600 + time[1].to_i * 60 + time[2].to_i
end

def elapsed_seconds
  @data[:state] == :started ? TIME_NOW - @data[:start] + @data[:elapsed] : @data[:elapsed]
end

@data = YAML.load_file(FILE_PATH) rescue {:start => TIME_NOW, :elapsed => 0, :state => :stopped}

case ARGV.first
  when "start"
    if @data[:state] == :stopped
      @data[:start] = TIME_NOW
      @data[:state] = :started
      save
    end
  when "stop"
    if @data[:state] == :started
      @data[:state] = :stopped
      @data[:elapsed] += (TIME_NOW - @data[:start]).to_i
      save
    end
  when "reset"
    @data[:elapsed] = 0
    @data[:start] = TIME_NOW
    @data[:state] = :started
    save
  when "set"
    @data[:elapsed] = get_seconds ARGV[1]
    @data[:start] = TIME_NOW
    save
end


puts @data[:state].to_s
puts format(elapsed_seconds)
