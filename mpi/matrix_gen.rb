#!/usr/bin/env ruby

def usage
  puts "#{File.basename(__FILE__)} <nrows> <ncols>"
  exit 1
end

def rand_float
 Random.rand()
end
 
class RandMatrix
  def initialize(r, c)
    @r = r
    @c = c
    @matrix = []
    (0...r).each do |i|
      @matrix[i] = []
      (0...c).each do |j|
        @matrix[i][j] = rand_float
      end
    end
  end
 
  def display
    puts @r, @c
    @matrix.each do |line|
      line.each do |value|
        puts "#{value} "
      end
    end
  end
end
 
if ARGV.length != 2
  usage
end

rows = ARGV[0].to_i
cols = ARGV[1].to_i
if rows == 0 || cols == 0
  usage
end

matrix = RandMatrix.new rows, cols
matrix.display
