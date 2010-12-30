class Runner
  require 'stringio'
  require 'pty'
  attr_reader :buffer, :running

#runner should grab the key off view?

  def initialize(script_path, script_name)
    @script_path = script_path
    @script_name = script_name
    @buffer = StringIO.new
    @running = false
  end
  
  def flush
    @buffer = StringIO.new
  end

  def run
    @running = true
    @buffer << "<p>$ ruby #{@script_name}</p>"
    cmd = %Q<ruby #{@script_path}>

    # IO.popen(cmd, 'w+') do |subprocess|
    #   # subprocess.write("Starting script")
    #   # subprocess.close_write
    #   subprocess.read.split("\n").each do |line|
    #     @buffer << "<p>#{line}</p>"
    #   end
    # end
    
    begin
      PTY.spawn(cmd) do |stdin, stdout, pid|
        begin
          stdin.each do |line|
            @buffer << "<p>#{line}</p>"
          end
        rescue Errno::EIO
        end
      end
    rescue PTY::ChildExited
      @buffer << "<p>ERROR! Consult a doctor.</p>"
    end
    @buffer << "<p>Script finished</p>"
    @running = false
  end

end

