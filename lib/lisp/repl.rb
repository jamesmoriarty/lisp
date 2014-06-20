#!/usr/bin/env ruby
require "coolline"

module Lisp
  def self.repl
    trap("SIGINT") { throw :exit }
    puts "ctrl-c to exit"
    catch(:exit) do
      loop do
        puts begin
          eval input.readline
        rescue Exception => e
          e.message
        end
      end
    end
  end

  def self.input
    Coolline.new
  end
end

if __FILE__ == $0
   Lisp.repl
end
