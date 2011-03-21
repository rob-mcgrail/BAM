require 'rubygems'
require 'builder'

$stdout.sync = true

PATH = File.expand_path(File.dirname(__FILE__))

SCRIPT = ARGV[0]

SCRIPT_PATH = PATH + '/' + SCRIPT

PUBLIC = 'lib/resources/public'

HOST = '0.0.0.0'

PORT = 5000

#constants for view:

JS = 'public/plainjax.js'
STYLESHEET = 'public/main.css'
SPEED = '100'

$key = Time.now.to_i

$:.unshift PATH
require 'lib/helpers/colourize.rb'
require 'lib/helpers/net_tools.rb'
require 'lib/runner.rb'
require 'lib/script_instances.rb'
require 'lib/server/server.rb'
require 'lib/resources/view.rb'

# $OPTS = Hash.new
# $OPTS[:host] = "0.0.0.0"
# $OPTS[:port] = 5000
# $OPTS[:root] = ""
# $OPTS[:script] = 'hello.rb'

Server.start

