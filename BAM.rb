PATH = File.expand_path(File.dirname(__FILE__))
require 'rubygems'
require 'builder'

$:.unshift PATH

require 'helpers/colourize.rb'
require 'helpers/net_tools.rb'
require 'resources/views.rb'
require 'server/server.rb'

SCRIPT = ARGV[0]

$OPTS = Hash.new
$OPTS[:host] = "0.0.0.0"
$OPTS[:port] = 5000
$OPTS[:root] = ""
$OPTS[:script] = 'hello.rb'


Views.build

server = Server
server.start

