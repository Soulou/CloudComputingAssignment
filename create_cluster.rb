#!/usr/bin/env ruby

# Load all gems from Gemfile
require 'rubygems'
require 'bundler/setup'
require 'openstack'
require 'net/ssh'

# Load script dependencies
SCRIPT_DIR = File.dirname __FILE__

require "#{SCRIPT_DIR}/lib/cloud"
require "#{SCRIPT_DIR}/lib/utils"

def usage
 puts "#{File.basename __FILE__} <nb_nodes>"
 exit -1
end

def create_cloud
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
    exit 1
  end
  puts "Waiting for the VMs to finalize their boot"
  sleep 30
  mpi_cloud(b)
  ansible_cloud(b)
end

def purge_cloud
  begin
    b = Cloud::Builder.new
    b.purge
  rescue => e
    puts "Fail to purge the cloud #{e.class} - #{e.message}"
    puts "Backtrace:\n#{e.backtrace.join("\n")}"
    exit 1
  end
end

def ansible_cloud(b = Cloud::Builder.new)
  ansible_dir = File.join SCRIPT_DIR, "ansible"
  FileUtils.mkdir_p ansible_dir
  b.write_hostsfile File.join(ansible_dir, "hosts"), :type => "ansible"
  FileUtils.cd ansible_dir
  system "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -c paramiko -i hosts mpi.yml --sudo"
end

def mpi_cloud(b = Cloud::Builder.new)
  mpi_dir = File.join SCRIPT_DIR, "mpi"
  FileUtils.mkdir_p mpi_dir
  b.write_hostsfile File.join(mpi_dir, "hosts"), :type => "mpi"
end

if ARGV.length == 1 and is_integer? ARGV[0]
  create_cloud
elsif ARGV.length == 1 and ARGV[0] == "--purge"
  purge_cloud
elsif ARGV.length == 1 and ARGV[0] == "--ansible"
  ansible_cloud
elsif ARGV.length == 1 and ARGV[0] == "--mpi"
  mpi_cloud
else
  usage
end

# vim: ts=2 sts=2 sw=2 expandtab
