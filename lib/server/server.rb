require 'rubygems'
require 'mongrel'

#
# The BAM server
#
# Visiting / creates a new Runner object, with a unique instance_key integer,
# used as its key from then on to distinguish it from other runners...
#
#
# The BAM 'UI' is in the @index var - it contains a number of simple ajax calls that
# start the Runner, and read and write to its buffer object, using urls like /read?instance_key_integer

class Server

  class Home < Mongrel::HttpHandler

    # Starts a new Runner (ScriptInstances#spawn) with a unique instance_key
    # Then creates the view with ajax calls which pass the same instance_key values
    def process(request, response)
      $key += 1
      instance_key = $key.to_s

      @index = View.new instance_key
      ScriptInstances.spawn instance_key

      response.start(200) do |head, out|
        head["Content-Type"] = "text/html"
        out.write @index.html
      end
    end
  end


  class Start < Mongrel::HttpHandler

    # Starts the Runner, identifying it by an instance_key param.
    # This is passed to ScriptInstances, which confirms the existence of the instance,
    # its state (running, not running) and then either runs it or warns the user that they're
    # clicking pointlessly...
    def process(request, response)
      instance_key = request.params["QUERY_STRING"].split('&').first

      if ScriptInstances.has? instance_key
        if ScriptInstances.is_running? instance_key
          response.start(200) do |head, out|
            head["Content-Type"] = "text/html"
            out.write "<p>$ ruby #{SCRIPT} is already running!</p>"
          end
        else
          ScriptInstances.flush instance_key
          ScriptInstances.run instance_key
          response.start(200) do |head, out|
              head["Content-Type"] = "text/html"
          end
        end
      else
        response.start(200) do |head, out|
            head["Content-Type"] = "text/html"
            out.write "<p>I seem to be a page generated for an old instance of BAM!</p><p>Try refreshing me (F5)"
        end
      end
    end

  end

  class Read < Mongrel::HttpHandler

    # Reads from the Runner's buffer object (StringIO), identifying it by an instance_key param.
    # Checks that runner with that key exists, rewinds the buffer, and outputs each line.
    def process(request, response)
      instance_key = request.params["QUERY_STRING"].split('&').first

      if ScriptInstances.has? instance_key
        response.start(200) do |head, out|
          head["Content-Type"] = "text/html"
          ScriptInstances.buffer(instance_key).rewind
          ScriptInstances.buffer(instance_key).read.each {|line| out.write line}
        end
      else
        response.start(200) do |head, out|
            head["Content-Type"] = "text/html"
        end
      end
    end
  end

  class Write < Mongrel::HttpHandler
    def process(request, response)
      instance_key = request.params["QUERY_STRING"].split('&').first
      string = request.params["QUERY_STRING"].split('&')[1]

      if ScriptInstances.has? instance_key
        response.start(200) do |head, out|
          head["Content-Type"] = "text/html"
          ScriptInstances.write(instance_key, string)
        end
      else
        response.start(200) do |head, out|
            head["Content-Type"] = "text/html"
            out.write "<p>I seem to be a page generated for an old instance of BAM!</p><p>Try refreshing me (F5)"
        end
      end
    end
  end


  def self.start

    config = Mongrel::Configurator.new :host => HOST, :port => PORT do
      listener do
        uri "/",                :handler => Home.new
        uri "/start",           :handler => Start.new
        uri "/read",            :handler => Read.new
        uri "/write",           :handler => Write.new
        uri "/public",          :handler => Mongrel::DirHandler.new(PUBLIC)
      end

      trap("INT") { stop }
      run
    end

    self.intro

    config.join
  end


  # Quick output on the host's terminal, identifying the host IP on the LAN and WAN
  def self.intro
    puts 'BAM!'.red_on_white
    begin
      puts "Visit #{NetTools.local_ip}:#{PORT} (or '#{HOST}:#{PORT}' on local machine)".white_on_green
    rescue
      puts "I can't tell you what your ip is, but locally I'm' '#{HOST}:#{PORT}'".green_on_white
    end
  end

end

