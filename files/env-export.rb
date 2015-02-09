#!/usr/bin/env ruby

require 'json'
require 'yaml'

env = ENV.to_hash.tap { |h| h.delete('_') }
cmd = ARGV[0]

case cmd
when '-j', '--json', 'json'
  puts env.to_json
when '-y', '--yml', '--yaml', 'yaml', 'yml'
  puts env.to_yaml
else
  puts "No format was defined, try --json or --yaml."
  exit 2
end

exit
