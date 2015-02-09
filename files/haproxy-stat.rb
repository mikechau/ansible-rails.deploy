#!/bin/env ruby
#
#       %%% %%%%%%%            |#|
#     %%%% %%%%%%%%%%%        |#|####
#   %%%%% %         %%%       |#|=#####
#  %%%%% %   @    @   %%      | | ==####
# %%%%%% % (_  ()  )  %%     | |    ===##
# %%  %%% %  \_    | %%      | |       =##
# %    %%%% %  u^uuu %%     | |         ==#
#       %%%% %%%%%%%%%      | |           V
#
#       "I mount my soul at /dev/null" - anonymous
#

require 'csv'
require 'json'
require 'optparse'
require 'socket'

help = <<-MSG

Usage: ./haproxy-stat [-b <backend-server>] [-c <current-server>] [-s <servers>] [-sock <socket file location>]

This script is a wrapper for parsing haproxy stats from its socket file.

Example usage:
./haproxy-stat -b hyperion -c titanium -s titanium,carbon

MSG


class HaproxyStat
  DEFAULT_SOCK = '/var/run/haproxy-stats.sock'

  attr_accessor :backend, :current_server, :servers, :socket

  def initialize(params = {})
    @backend = params[:backend]
    @current_server = params[:current_server]
    @servers = params[:servers]
    @socket = params[:socket] || DEFAULT_SOCK
  end

  def current_server_up?
    current_server_stats[0][:status] == 'UP'
  end

  def all_servers_up?
    all_server_stats.map { |s| s[:status] }.uniq == ['UP']
  end

  def some_servers_up?
    some_servers = servers - [current_server]

    backend_stats.
      select { |s| some_servers.include? s[:svname] }.
      map { |s| s[:status] }.
      uniq.
      include? 'UP'
  end

  private

  def current_server_stats
    backend_stats.select { |s| s[:svname] == current_server }
  end

  def all_server_stats
    backend_stats.select { |s| servers.include? s[:svname] }
  end

  def backend_stats
    @backend_stats ||= stats.select { |s| s[:_pxname] == backend && s[:_pxname] != 'BACKEND' }
  end

  def stats
    data = unixsock('show stat')
    csv = CSV.new(data, :headers => true, :header_converters => :symbol, :converters => :all)
    csv.to_a.map { |r| r.to_hash }
  end

  def unixsock(command)
    output = ''
    runs = 0

    begin
      ctl = UNIXSocket.open(socket)
      if ctl
        ctl.write "#{command}\r\n"
      else
        puts "cannot talk to #{socket}"
      end
    rescue Errno::EPIPE
      ctl.close
      sleep 0.5
      runs += 1
      if  runs < 4
        retry
      else
        puts "the unix socket at #{socket} closed before we could complete this request"
        exit 2
      end
    end
    while (line = ctl.gets)
      unless line =~ /Unknown command/
        output << line
      end
    end
    ctl.close

    output
  end
end

options = {
  :backend => nil,
  :current_server => nil,
  :servers => [],
  :socket => HaproxyStat::DEFAULT_SOCK
}

optparse = OptionParser.new do |opts|
  opts.banner = help

  opts.on('--backend=BACKEND', 'Haproxy backend server' ) do |backend|
    options[:backend] = backend
  end

  opts.on('--current-server=CURRENT_SERVER', 'Haproxy current server' ) do |server|
    options[:current_server] = server
  end

  opts.on('--servers=[x,y,z]', Array, 'Haproxy list of servers' ) do |servers|
    options[:servers] = servers
  end

  opts.on('--sock=SOCKET', 'Haproxy socket file') do |socket|
    options[:socket] = socket
  end

  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
end

optparse.parse!

unless options[:backend] && !options[:backend].empty?
  STDERR.print "ERROR: Missing argument for backend."
  exit 2
end

unless options[:current_server] && !options[:current_server].empty?
  STDERR.print "ERROR: Missing argument for current_server."
  exit 2
end

unless options[:servers] && options[:servers].any?
  STDERR.print "ERROR: Missing argument for servers."
  exit 2
end

haproxy_stat = HaproxyStat.new(options)

results = {
  current_server: haproxy_stat.current_server_up?,
  all_servers_up: haproxy_stat.all_servers_up?,
  some_servers_up: haproxy_stat.some_servers_up?
}

if haproxy_stat.all_servers_up? || haproxy_stat.some_servers_up?
  results[:msg] = 'READY'
  results[:ready] = true
  STDOUT.print results.to_json
  exit
else
  results[:msg] = 'NOT READY'
  results[:ready] = false
  STDERR.print results.to_json
  exit 1
end
