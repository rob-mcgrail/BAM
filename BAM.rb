require 'rubygems'
require 'builder'

$stdout.sync = true

PATH = File.expand_path(File.dirname(__FILE__))

SCRIPT = ARGV[0]

SCRIPT_PATH = PATH + '/' + SCRIPT

PUBLIC = 'resources/public'

HOST = '0.0.0.0'

PORT = 5000

KEY = Time.now.to_i

$:.unshift PATH
require 'helpers/colourize.rb'
require 'helpers/net_tools.rb'
require 'runner.rb'
require 'resources/view.rb'
require 'script_instances.rb'
require 'server/server.rb'

# $OPTS = Hash.new
# $OPTS[:host] = "0.0.0.0"
# $OPTS[:port] = 5000
# $OPTS[:root] = ""
# $OPTS[:script] = 'hello.rb'

server = Server
server.start

