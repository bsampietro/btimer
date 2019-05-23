#!/usr/bin/ruby

require 'yaml'

TIME_NOW = Time.now

class Timer
  attr_reader :data
  
  def initialize(data)
    @data = data
  end
  
  def start
    return if @data[:state] != :stopped
    @data[:start] = TIME_NOW
    @data[:state] = :started
  end
  
  def stop
    return if @data[:state] != :started
    @data[:state] = :stopped
    @data[:stopped_at] = TIME_NOW
    @data[:elapsed] += (TIME_NOW - @data[:start]).to_i
  end
  
  def set(str)
    if str
      @data[:elapsed] = self.class.get_seconds(str)
    else
      @data[:elapsed] = 0
      @data[:state] = :started
    end
    @data[:start] = TIME_NOW
  end
  
  def add(minutes)
    @data[:elapsed] += minutes * 60
  end
  
  def sub(minutes)
    @data[:elapsed] -= minutes * 60
  end
  
  def elapsed_seconds
    @data[:state] == :started ?
      (TIME_NOW - @data[:start]).to_i + @data[:elapsed] : @data[:elapsed]
  end
  
  def elapsed_last_stop_seconds
    TIME_NOW - @data[:stopped_at]
  end
  
  def formatted_elapsed_seconds
    self.class.formatted_output(self.elapsed_seconds)
  end
  
  def formatted_elapsed_last_stop_seconds
    self.class.formatted_output(self.elapsed_last_stop_seconds)
  end
  
  def formatted_state
    @data[:state].to_s.capitalize
  end
  
  def self.formatted_output(seconds)
    secs  = seconds.to_i
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
  def self.get_seconds(str)
    time = str.split(':')
    time[0].to_i * 3600 + time[1].to_i * 60 + time[2].to_i
  end
end

FILE_DIR = File.join(ENV['HOME'], '.btimer')
Dir.mkdir FILE_DIR unless File.exists? FILE_DIR

FILE_PATH = File.join(FILE_DIR, 'data.yml')

def save(data)
  File.open(FILE_PATH, 'w') do |out|
    YAML.dump(data, out)
  end
end

data = YAML.load_file(FILE_PATH) rescue
    {:start => TIME_NOW, :elapsed => 0,
      :state => :stopped, :stopped_at => TIME_NOW}

t = Timer.new(data)

case ARGV[0]
  when "start"
    t.start
    puts "Since last stop: " + t.formatted_elapsed_last_stop_seconds
  when "stop"
    t.stop
  when "set"
    t.set(ARGV[1])
    t.start if ARGV[2] == "start"
    t.stop if ARGV[2] == "stop"
  when "add"
    t.add ARGV[1].to_i
    t.start if ARGV[2] == "start"
    t.stop if ARGV[2] == "stop"
  when "sub"
    t.sub ARGV[1].to_i
    t.start if ARGV[2] == "start"
    t.stop if ARGV[2] == "stop"
  when "help"
    puts "timer [start|stop|set|add|sub]"
end

save t.data if ["start", "stop", "set", "add", "sub"].include? ARGV[0]

puts t.formatted_state
puts t.formatted_elapsed_seconds

