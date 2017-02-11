#!/usr/bin/env ruby

require "coolline"
require "coderay"

require "lisp/ext/proc"

module Lisp
  class REPL
    attr_reader :io, :input

    def initialize
      @io = Coolline.new do |config|
        config.transform_proc = proc do
          CodeRay.scan(config.line, :clojure).term
        end
      end

      reset_input!
    end

    def run
      trap("SIGINT") { throw :exit }

      puts "ctrl-c to exit"

      catch(:exit) do
        loop do
          begin
            @input += io.readline prompt

            if open_count == close_count
              puts Lisp.eval input

              reset_input!
            end
          rescue Exception => e
            puts e.message

            reset_input!
          end
        end
      end
    end

    private

    def prompt
      count = open_count - close_count
      char  = count > 0 ? ?( : ?)
      "#{char * count}> "
    end

    def reset_input!
      @input = String.new
    end

    def open_count
      tokens.count(?()
    end

    def close_count
      tokens.count(?))
    end

    def tokens
      Lisp.tokenize input
    end
  end
end
