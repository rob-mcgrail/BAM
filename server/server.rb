require 'rubygems'
require 'mongrel'

class Server
    
  class Home < Mongrel::HttpHandler

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

#this doesn't need a conditoinal at all I think:

  class Read < Mongrel::HttpHandler
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
  
  def self.start

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

