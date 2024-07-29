#!/usr/bin/env ruby

require_relative File.expand_path('~/.config/nyash/nyashrc')
require 'readline'

ENV['PATH'] = PATH

# Find binary files from PATH
def findBin(command)
  paths = ENV['PATH'].split(':')
  paths.each do |path|
    executable = File.join(path, command)
    return executable if File.executable?(executable) && !File.directory?(executable)
  end
  nil
end

# Log history
def logCmd(command)
  File.open(HISTORY_FILE, 'a') do |file|
    file.puts(command)
  end
end

# 'Snippet'
def completeCommand(input)
  currentInput = input.chomp
  if currentInput.empty?
    dir = Dir.pwd
    entries = Dir.entries(dir).select { |f| !File.directory?(File.join(dir, f)) }
    entries.sort
  else
    dir = Dir.pwd
    entries = Dir.entries(dir).select { |f| f.start_with?(currentInput) && !File.directory?(File.join(dir, f)) }
    entries.sort
  end
end

Readline.completion_proc = proc { |input| completeCommand(input) }
Readline::HISTORY.push(*File.readlines(HISTORY_FILE).map(&:chomp)) if File.exist?(HISTORY_FILE)

loop do
  # Scan input
  input = Readline.readline(PROMPT, true)
  break if input.nil?
  next if input.empty?
  logCmd(input)
  
  command, *args = input.split
  next if command.nil?

  # Read command
  case command
  when "helloWorld"
    helloWorld
  when "exit"
    break
  else
    if respond_to?(command, true) # Call functions from config
      send(command, *args)
    else
      executable = findBin(command)
      if executable
        pid = spawn(executable, *args)
        Process.wait(pid)
      else
        puts "nyash: #{command}: No such file or directory *><"
      end
    end
  end
end
  
