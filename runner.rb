class Runner
  require 'stringio'
  attr_reader :buffer, :running

  def initialize(script_path, script_name)
    @buffer = StringIO.new
    @running = false
  end

  def run
      @running = true
      @buffer << "<p>$ ruby #{script_name}</p>"
      cmd = %Q<ruby #{script_path}>

      IO.popen(cmd, 'w+') do |subprocess|
        subprocess.write("Starting script")
        subprocess.close_write
        subprocess.read.split("\n").each do |line|
          @buffer << "<p>#{line}</p>"
        end
      end
      @buffer << "<p>Script finished</p>"
      @running = false
  end

end

