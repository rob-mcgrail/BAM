require 'rubygems'
require 'mongrel'
require 'stringio'

PUBLIC = 'resources/public'
HOST = '0.0.0.0'
PORT = 5000
SCRIPT = 'hello.rb'

class Server

  class Home < Mongrel::HttpHandler
    def process(request, response)
      response.start(200) do |head, out|
        head["Content-Type"] = "text/html"
        out.write Views.index_html
      end
    end
  end

  class Start < Mongrel::HttpHandler
    def process(request, response)
      if $running == true
        response.start(200) do |head, out|
          head["Content-Type"] = "text/html"
          out.write "<p>$ ruby #{@script} is already running!</p>"
        end
      else

        $buffer = StringIO.new

        @script = SCRIPT
        @path = File.expand_path(File.dirname(__FILE__)) + '/../'
        @script_path = @path + @script

        $buffer << "<p>$ ruby #{@script}</p>"

        cmd = %Q<ruby #{@script_path}>

        $running = true
        IO.popen(cmd, 'w+') do |subprocess|
          subprocess.write("Starting script")
          subprocess.close_write
          subprocess.read.split("\n").each do |l|
            $buffer << "<p>#{l}</p>"
          end
        end

        $buffer << "<p>Script finished</p>"; $running = false

        response.start(200) do |head, out|
            head["Content-Type"] = "text/html"
            load @script
            out.write "<p></p>"
        end
      end
    end
  end

  class Read < Mongrel::HttpHandler
    def process(request, response)
      response.start(200) do |head, out|
        head["Content-Type"] = "text/html"
        $buffer.rewind
        $buffer.read.each {|line| out.write line}
      end
    end
  end

  def self.start
    $buffer = StringIO.new
    $stdout.sync = true

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

    puts 'BAM!'.red_on_white
    puts "Visit #{NetTools.local_ip}:#{PORT} (or '#{HOST}:#{PORT}' on local machine)".white_on_green

    config.join
  end

end

