#!/usr/bin/env ruby

# Load all gems from Gemfile
require 'rubygems'
require 'bundler/setup'
require 'openstack'

# Load script dependencies
script_dir = File.dirname __FILE__
require "#{script_dir}/lib/cloud"
require "#{script_dir}/lib/utils"

def usage
 puts "#{File.basename __FILE__} <nb_nodes>"
 exit -1
end


if ARGV.length != 1
  if !is_integer?(ARGV[0])
    usage
  else
  end
end

nb_nodes = ARGV[0].to_i
if nb_nodes <= 0
  puts "nb_nodes > 0"
  usage
end

begin
  Cloud::Builder.new(nb_nodes)
rescue => e
  puts "Exception #{e.class} occured: #{e.message}"
  puts "Backtrace:\n#{e.backtrace.join("\n")}"
end

# vim: ts=2 sts=2 sw=2 expandtab
