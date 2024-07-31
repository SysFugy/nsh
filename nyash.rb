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

# Change directory
def change_directory(dir)
  if Dir.exist?(dir)
    Dir.chdir(dir)
  else
    puts "nyash: cd: #{dir}: No such file or directory"
  end
end

# 'Snippet'
def completeCommand(input)
  currentInput = input.chomp
  dir = Dir.pwd

  # Files list
  entries = Dir.entries(dir).select do |entry|
    fullPath = File.join(dir, entry)
    entry.start_with?(currentInput) && !File.symlink?(fullPath)
  end

  # Sort result
  entries.sort
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
  when "cd"
    dir = args.join(' ') 
    dir = File.expand_path(dir)
    change_directory(dir)
  else
    if respond_to?(command, true)
      send(command, *args)
    else
      executable = findBin(command)
      if executable
        pid = spawn(executable, *args)
        Process.wait(pid)
      else
        puts "nyash: #{command}: Cannot execute this *><"
      end
    end
  end
end
