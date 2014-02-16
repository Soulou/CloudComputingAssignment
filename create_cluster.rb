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


if ARGV.length == 1 and is_integer? ARGV[0]
  nb_nodes = ARGV[0].to_i
  if nb_nodes <= 0
    puts "nb_nodes > 0"
    usage
  end

  begin
    b = Cloud::Builder.new
    b.build nb_nodes
  rescue => e
    puts "Exception #{e.class} occured: #{e.message}"
    puts "Backtrace:\n#{e.backtrace.join("\n")}"
  end
elsif ARGV.length == 1 and ARGV[0] == "--purge"
  begin
    b = Cloud::Builder.new
    b.purge
  rescue => e
    puts "Fail to purge the cloud #{e.class} - #{e.message}"
    puts "Backtrace:\n#{e.backtrace.join("\n")}"
  end
else
  usage
end

# vim: ts=2 sts=2 sw=2 expandtab
