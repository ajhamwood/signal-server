require 'sinatra/base'

module SignalServer
  class App < Sinatra::Base
    get '/' do
      status 200
      body ''
    end
  end
end
