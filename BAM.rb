require 'rubygems'
require 'builder'

PATH = File.expand_path(File.dirname(__FILE__))

SCRIPT = ARGV[0]

SCRIPT_PATH = PATH + '/' + SCRIPT

PUBLIC = 'resources/public'

HOST = '0.0.0.0'

PORT = 5000

$:.unshift PATH



require 'helpers/colourize.rb'
require 'helpers/net_tools.rb'
require 'runner.rb'
require 'resources/view.rb'
require 'server/server.rb'

$OPTS = Hash.new
$OPTS[:host] = "0.0.0.0"
$OPTS[:port] = 5000
$OPTS[:root] = ""
$OPTS[:script] = 'hello.rb'

View.new_session
server = Server
server.start

