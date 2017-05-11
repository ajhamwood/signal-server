$stdout.sync = true

require './app'
require './backend'
use SignalServer::Backend
run SignalServer::App
