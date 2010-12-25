require 'rubygems'
require 'mongrel'


class Server

  class Home < Mongrel::HttpHandler

    def initialize
      @index = View.new
      super
    end

    def process(request, response)
      response.start(200) do |head, out|
        head["Content-Type"] = "text/html"
        out.write @index.html
      end
    end
  end


  class Start < Mongrel::HttpHandler

    def initialize
      super
      @script_instance = Runner.new(SCRIPT_PATH, SCRIPT)
    end

    def process(request, response)
      if @script_instance.runner == true
        response.start(200) do |head, out|
          head["Content-Type"] = "text/html"
          out.write "<p>$ ruby #{SCRIPT} is already running!</p>"
        end
      else
        @script_instance.run #these can live in a big hash with the view id as key

        response.start(200) do |head, out|
            head["Content-Type"] = "text/html"
        end
      end
    end

  end

  class Read < Mongrel::HttpHandler
    def process(request, response)
      if @script_instance.runner == true
        response.start(200) do |head, out|
          head["Content-Type"] = "text/html"
          @script_instance.buffer.rewind
          @script_instance.buffer.read.each {|line| out.write line}
        end
      else
        response.start(200) do |head, out|
          head["Content-Type"] = "text/html"
        end
      end
    end
  end

  def self.start
    $stdout.sync = true

#
# What about a unique hash for start? It could match that against read somehow?
#

    config = Mongrel::Configurator.new :host => HOST, :port => PORT do
      listener do
        uri "/",                :handler => Home.new
        uri "/start",           :handler => Start.new
        uri "/read",            :handler => Read.new
        uri "/public",          :handler => Mongrel::DirHandler.new(PUBLIC)
      end

      trap("INT") { stop }
      run
    end

    self.intro

    config.join
  end

  def self.intro
    puts 'BAM!'.red_on_white
    begin
      puts "Visit #{NetTools.local_ip}:#{PORT} (or '#{HOST}:#{PORT}' on local machine)".white_on_green
    rescue
      puts "I can't tell you what your ip is, but locally I'm' '#{HOST}:#{PORT}'".green_on_white
    end
  end

end

